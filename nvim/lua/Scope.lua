-- File: fuzzy-finder.lua
-- Usage: :FuzzyFind or :FF
-- Keybind: <leader>ff (configurable)

local M = {}

-- Configuration with defaults
local config = {
  width = 0.4,
  height = 0.4,
  border = "single",
  title = "  Fuzzy Finder  ",
  show_icons = true,
  icon_style = "nerd",  -- "nerd", "emoji", "none"
  file_ignore_patterns = {
    "^.git/",
    "^node_modules/",
    "^.venv/",
    "^target/",
    "^build/",
    "%.o$",
    "%.a$",
    "%.so$",
    "%.pyc$",
    "%.class$",
  },
  max_results = 200,
  preview = true,
  preview_width = 0.4,
  keybind = "<leader>ff",  -- Set to false to disable
  sort_by = "frecency",    -- "frecency", "recent", "filename"
  show_hidden = false,     -- Show hidden files
}

-- State management
local state = {
  file_cache = {},
  cache_time = 0,
  CACHE_TTL = 60 * 5,  -- 5 minutes cache
  search_history = {},
  history_index = 0,
}

-- Initialize nvim-web-devicons if needed
local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
if not has_devicons then
  devicons = { get_icon = function() return nil, nil end }
end

-- Get icon with fallback
local function get_icon(filename, is_directory)
  if not config.show_icons then return "" end
  
  if config.icon_style == "nerd" then
    if is_directory then return " " end
    local icon, _ = devicons.get_icon(filename)
    return icon and (icon .. " ") or " "
  elseif config.icon_style == "emoji" then
    return is_directory and "📁 " or "📄 "
  end
  return ""
end

-- Improved theme colors with better fallbacks
local function get_theme_colors()
  local colors = {
    bg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Normal")), "bg#"),
    fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Normal")), "fg#"),
    border = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("FloatBorder")), "fg#"),
    cursorline = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("CursorLine")), "bg#"),
    directory = "#4EC9B0",
    match = "#FFD700",
    preview = "#8FBCBB",
  }

  -- Better fallback colors based on background darkness
  local bg_dark = vim.o.background == "dark"
  colors.bg = colors.bg ~= "" and colors.bg or (bg_dark and "#1e1e2e" or "#f5f5f5")
  colors.fg = colors.fg ~= "" and colors.fg or (bg_dark and "#cdd6f4" or "#333333")
  colors.border = colors.border ~= "" and colors.border or (bg_dark and "#7f849c" or "#aaaaaa")
  colors.cursorline = colors.cursorline ~= "" and colors.cursorline or (bg_dark and "#313244" or "#e0e0e0")

  return colors
end

-- More robust ignore pattern checking
local function should_ignore(filepath)
  if not config.show_hidden and filepath:match("/%.[^/]+$") then
    return true
  end
  
  for _, pattern in ipairs(config.file_ignore_patterns) do
    if filepath:match(pattern) then
      return true
    end
  end
  return false
end

-- Async file scanning with vim.loop
local function scan_directory_async(dir, callback)
  local files = {}
  local function scan(current_dir)
    local handle = vim.loop.fs_scandir(current_dir)
    if not handle then return end

    local function process_entry()
      local name, typ = vim.loop.fs_scandir_next(handle)
      if not name then
        if #files >= config.max_results then
          return callback(files)
        end
        return callback(files)
      end

      local full_path = current_dir .. "/" .. name
      if not should_ignore(full_path) then
        if typ == "directory" then
          scan(full_path)
        else
          table.insert(files, full_path)
          if #files >= config.max_results then
            return callback(files)
          end
        end
      end
      vim.schedule(process_entry)
    end

    process_entry()
  end

  scan(dir)
end

-- Cached file listing with async support
local function get_files(callback)
  local cwd = vim.fn.getcwd()
  local now = os.time()

  if state.file_cache[cwd] and now - state.cache_time < state.CACHE_TTL then
    return callback(state.file_cache[cwd])
  end

  scan_directory_async(cwd, function(files)
    state.file_cache[cwd] = files
    state.cache_time = now
    callback(files)
  end)
end

-- Improved fuzzy matching algorithm
local function fuzzy_match(str, pattern)
  local pattern_chars = vim.split(pattern:lower(), "")
  local str_chars = vim.split(str:lower(), "")
  local pattern_index = 1
  
  for _, c in ipairs(str_chars) do
    if c == pattern_chars[pattern_index] then
      pattern_index = pattern_index + 1
      if pattern_index > #pattern_chars then
        return true
      end
    end
  end
  return false
end

-- Sort files based on configuration
local function sort_files(files)
  if config.sort_by == "frecency" then
    table.sort(files, function(a, b)
      local a_stat = vim.loop.fs_stat(a)
      local b_stat = vim.loop.fs_stat(b)
      local a_score = (a_stat and a_stat.mtime.sec or 0) * 0.5 + #a * 0.5
      local b_score = (b_stat and b_stat.mtime.sec or 0) * 0.5 + #b * 0.5
      return a_score > b_score
    end)
  elseif config.sort_by == "recent" then
    table.sort(files, function(a, b)
      local a_stat = vim.loop.fs_stat(a)
      local b_stat = vim.loop.fs_stat(b)
      return (a_stat and a_stat.mtime.sec or 0) > (b_stat and b_stat.mtime.sec or 0)
    end)
  else -- "filename"
    table.sort(files, function(a, b)
      return a:lower() < b:lower()
    end)
  end
  return files
end

-- Create popup window with improved UI
local function create_popup(results, query, is_grep)
  local colors = get_theme_colors()
  local buf = vim.api.nvim_create_buf(false, true)
  
  -- Validate buffer creation
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  local width = math.floor(vim.o.columns * config.width)
  local height = math.floor(vim.o.lines * config.height)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  -- Set highlight groups
  vim.api.nvim_set_hl(0, "FuzzyNormal", { bg = colors.bg, fg = colors.fg })
  vim.api.nvim_set_hl(0, "FuzzyBorder", { fg = colors.border })
  vim.api.nvim_set_hl(0, "FuzzyCursorLine", { bg = colors.cursorline })
  vim.api.nvim_set_hl(0, "FuzzyDirectory", { fg = colors.directory, bold = true })
  vim.api.nvim_set_hl(0, "FuzzyMatch", { fg = colors.match, bold = true })
  vim.api.nvim_set_hl(0, "FuzzyPreview", { bg = colors.preview })

  -- Create window with error handling
  local ok, win = pcall(vim.api.nvim_open_win, buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = config.border,
    title = is_grep and "🔍 Grep Search" or config.title,
    title_pos = "center",
  })

  if not ok or not win or not vim.api.nvim_win_is_valid(win) then
    if buf and vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
    return
  end

  -- Rest of your create_popup function remains the same...
  vim.api.nvim_win_set_option(win, "winhl", 
    "Normal:FuzzyNormal," ..
    "NormalNC:FuzzyNormal," ..
    "FloatBorder:FuzzyBorder," ..
    "CursorLine:FuzzyCursorLine")

  -- ... [rest of your existing create_popup implementation]

  -- Prepare content with better display
  local lines = {}
  local highlights = {}

  for i, item in ipairs(results) do
    local filepath = is_grep and item.filepath or item
    local is_dir = vim.fn.isdirectory(filepath) == 1
    local filename = vim.fn.fnamemodify(filepath, ":t")
    local icon = get_icon(filename, is_dir)
    local display_path = vim.fn.fnamemodify(filepath, ":~:.")
    local line = icon .. display_path

    if is_grep then
      line = line .. " | " .. item.text:gsub("^%s*(.-)%s*$", "%1")
    end

    table.insert(lines, line)

    -- Add highlights
    table.insert(highlights, {
      line = i-1,
      col = 0,
      end_col = #icon,
      hl_group = is_dir and "FuzzyDirectory" or "Normal"
    })

    -- Highlight matches
    if query and query ~= "" then
      local lower_path = display_path:lower()
      local lower_query = query:lower()
      local start_pos = lower_path:find(lower_query, 1, true)
      while start_pos do
        table.insert(highlights, {
          line = i-1,
          col = #icon + start_pos - 1,
          end_col = #icon + start_pos - 1 + #query,
          hl_group = "FuzzyMatch"
        })
        start_pos = lower_path:find(lower_query, start_pos + 1, true)
      end
    end
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf, -1, hl.hl_group, hl.line, hl.col, hl.end_col)
  end

  -- Create preview window
  local preview_win = nil
  local preview_buf = nil

  local function update_preview()
    if not config.preview then return end
    
    local line = vim.api.nvim_get_current_line()
    local idx = vim.fn.line(".")
    local selected = results[idx]
    
    if not selected or (not is_grep and vim.fn.isdirectory(selected) == 1) then
      if preview_win and vim.api.nvim_win_is_valid(preview_win) then
        vim.api.nvim_win_close(preview_win, true)
        preview_win = nil
      end
      return
    end

    if preview_win and not vim.api.nvim_win_is_valid(preview_win) then
      preview_win = nil
    end

    if not preview_win then
      local preview_width = math.floor(width * config.preview_width)
      preview_win = vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), false, {
        relative = "win",
        win = win,
        width = preview_width,
        height = height - 2,
        col = width - preview_width - 2,
        row = 1,
        style = "minimal",
        border = "rounded",
      })
      vim.api.nvim_win_set_option(preview_win, "winhl", "Normal:FuzzyPreview,NormalNC:FuzzyPreview")
    end

    preview_buf = vim.api.nvim_win_get_buf(preview_win)
    vim.api.nvim_buf_set_option(preview_buf, "modifiable", true)
    vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, {})
    
    if is_grep then
      local content = selected.text
      if selected.line_number then
        content = "Line " .. selected.line_number .. ": " .. content
      end
      vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, {content})
    else
      local ok, lines = pcall(vim.fn.readfile, selected)
      if ok and lines then
        vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, lines)
        vim.api.nvim_buf_set_option(preview_buf, "filetype", vim.fn.fnamemodify(selected, ":e"))
      else
        vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, {"Unable to preview file"})
      end
    end
    vim.api.nvim_buf_set_option(preview_buf, "modifiable", false)
  end

  -- Window management
  local function close_window()
    if preview_win and vim.api.nvim_win_is_valid(preview_win) then
      vim.api.nvim_win_close(preview_win, true)
    end
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
    if preview_buf and vim.api.nvim_buf_is_valid(preview_buf) then
      vim.api.nvim_buf_delete(preview_buf, { force = true })
    end
  end

  -- Enhanced keybindings
  local keymaps = {
    { "n", "<CR>", function()
      local idx = vim.fn.line(".")
      local selected = results[idx]
      if selected then
        close_window()
        local target = is_grep and selected.filepath or selected
        if vim.fn.isdirectory(target) == 1 then
          vim.cmd("cd " .. vim.fn.fnameescape(target))
        else
          vim.cmd("edit " .. vim.fn.fnameescape(target))
          if is_grep and selected.line_number then
            vim.api.nvim_win_set_cursor(0, {selected.line_number, 0})
          end
        end
      end
    end },
    { "n", "<Esc>", close_window },
    { "n", "<Tab>", update_preview },
    { "n", "<C-p>", function()
      if state.history_index > 1 then
        state.history_index = state.history_index - 1
        close_window()
        M.fuzzy_find(state.search_history[state.history_index])
      end
    end },
    { "n", "<C-n>", function()
      if state.history_index < #state.search_history then
        state.history_index = state.history_index + 1
        close_window()
        M.fuzzy_find(state.search_history[state.history_index])
      end
    end },
    { "n", "/", function()
      vim.ui.input({ prompt = "Search: " }, function(input)
        if input then 
          close_window()
          M.fuzzy_find(input) 
        end
      end)
    end },
    { "n", "<C-f>", function()
      vim.ui.input({ prompt = "Grep: " }, function(input)
        if input then 
          close_window()
          M.grep_search(input) 
        end
      end)
    end },
  }

  for _, map in ipairs(keymaps) do
    vim.api.nvim_buf_set_keymap(buf, map[1], map[2], "", {
      callback = map[3],
      noremap = true,
      silent = true,
    })
  end

  -- Autocommands
  if config.preview then
    vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, {
      buffer = buf,
      callback = update_preview,
    })
  end

  vim.api.nvim_create_autocmd({"BufLeave", "WinLeave"}, {
    buffer = buf,
    once = true,
    callback = close_window
  })

  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
end

-- File search function
function M.fuzzy_find(query)
  query = query or ""
  
  -- Add to search history
  if query ~= "" then
    table.insert(state.search_history, query)
    state.history_index = #state.search_history
  end

  get_files(function(files)
    files = sort_files(files)
    local results = {}

    if query == "" then
      for i = 1, math.min(#files, config.max_results) do
        table.insert(results, files[i])
      end
    else
      for _, filepath in ipairs(files) do
        local display_path = vim.fn.fnamemodify(filepath, ":~:.")
        if fuzzy_match(display_path, query) then
          table.insert(results, filepath)
          if #results >= config.max_results then break end
        end
      end
    end

    if #results == 0 then
      vim.notify("No matching files found", vim.log.levels.WARN)
      return
    end

    -- Schedule the popup creation to avoid timing issues
    vim.schedule(function()
      create_popup(results, query, false)
    end)
  end)
end

-- Grep search function using ripgrep
function M.grep_search(query)
  if query == "" then return end
  
  vim.notify("Searching with ripgrep...", vim.log.levels.INFO)
  vim.fn.jobstart("rg --vimgrep --smart-case " .. vim.fn.shellescape(query), {
    cwd = vim.fn.getcwd(),
    stdout_buffered = true,
    on_stdout = function(_, data)
      local results = {}
      for _, line in ipairs(data) do
        local filepath, line_number, column, text = line:match("^([^:]+):(%d+):(%d+):(.*)$")
        if filepath then
          table.insert(results, {
            filepath = filepath,
            line_number = tonumber(line_number),
            column = tonumber(column),
            text = text,
          })
        end
      end
      vim.schedule(function()
        if #results > 0 then
          create_popup(results, query, true)
        else
          vim.notify("No matches found", vim.log.levels.WARN)
        end
      end)
    end
  })
end

-- Setup function with keybinds
function M.setup(user_config)
  config = vim.tbl_deep_extend("force", config, user_config or {})

  -- Set up keybinds
  if config.keybind then
    vim.keymap.set('n', config.keybind, M.fuzzy_find, { desc = "Fuzzy find files" })
  end
  if config.grep_keybind then
    vim.keymap.set('n', config.grep_keybind, function()
      vim.ui.input({ prompt = "Grep: " }, function(input)
        if input then M.grep_search(input) end
      end)
    end, { desc = "Grep search with ripgrep" })
  end

  -- Create commands
  vim.api.nvim_create_user_command("FuzzyFind", function(opts)
    M.fuzzy_find(opts.args)
  end, { nargs = "?" })

  vim.api.nvim_create_user_command("FF", function(opts)
    M.fuzzy_find(opts.args)
  end, { nargs = "?" })
end
-- Create commands
vim.api.nvim_create_user_command("FuzzyFind", function(args)
  M.fuzzy_find(args.args)
end, { nargs = "?", complete = "file" })

vim.api.nvim_create_user_command("FF", function(args)
  M.fuzzy_find(args.args)
end, { nargs = "?", complete = "file" })

vim.api.nvim_create_user_command("FuzzyGrep", function(args)
  M.grep_search(args.args)
end, { nargs = "?", complete = "file" })

-- Clear cache on directory change
vim.api.nvim_create_autocmd("DirChanged", {
  callback = function()
    state.file_cache = {}
  end,
})

return M
