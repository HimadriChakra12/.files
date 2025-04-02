-- zoxide-like Nvim plugin

local M = {}

local history_file = vim.fn.stdpath("data") .. "/zoxide_nvim_history.txt"
local history = {}

-- Load history from file
local function load_history()
  history = {}
  local file = io.open(history_file, "r")
  if file then
    for line in file:lines() do
      table.insert(history, line)
    end
    file:close()
  end
end

-- Save history to file
local function save_history()
  local file = io.open(history_file, "w")
  if file then
    for _, dir in ipairs(history) do
      file:write(dir .. "\n")
    end
    file:close()
  end
end

-- Normalize path for comparison
local function normalize_path(path)
  path = vim.fn.fnamemodify(path, ":p")
  path = path:gsub("\\", "/"):gsub("/+", "/"):gsub("/$", "")
  return path
end

-- Check if path exists in history
local function path_in_history(path)
  local normalized_path = normalize_path(path)
  for _, dir in ipairs(history) do
    if normalize_path(dir) == normalized_path then
      return true
    end
  end
  return false
end

-- Add directory to history
local function add_to_history(dir)
  -- Don't add if already in history
  if path_in_history(dir) then
    return
  end

  -- Add to beginning of history
  table.insert(history, 1, normalize_path(dir))

  -- Limit history size (e.g., to 100 entries)
  if #history > 100 then
    table.remove(history, #history)
  end
  save_history()
end

-- Fuzzy find and jump
local function jump(query)
  query = query or ""
  local results = {}
  
  -- If no query provided, show all history
  if query == "" then
    results = history
  else
    -- Simple fuzzy matching (case insensitive)
    local pattern = query:gsub(".", function(c) return ".*" .. c:lower() end)
    for _, dir in ipairs(history) do
      local dir_lower = dir:lower()
      if dir_lower:find(pattern) or dir_lower:find(query:lower(), 1, true) then
        table.insert(results, dir)
      end
    end
  end

  if #results == 0 then
    -- Try expanding the query as a direct path
    local expanded_query = vim.fn.expand(query)
    if vim.fn.isdirectory(expanded_query) == 1 then
      vim.cmd("cd " .. vim.fn.fnameescape(expanded_query))
      add_to_history(expanded_query)
    else
      vim.notify("No matching directories found in history or as a direct directory.", vim.log.levels.WARN)
    end
    return
  end

  if #results == 1 then
    local selected = results[1]
    vim.cmd("cd " .. vim.fn.fnameescape(selected))
    add_to_history(selected)
  else
    vim.ui.select(results, {
      prompt = "Select directory to jump to:",
      format_item = function(item)
        return vim.fn.fnamemodify(item, ":~")
      end,
      kind = "selector",
      -- Set fixed height (maximum 15 items, but won't exceed window height)
      size = math.min(15, #results, vim.o.lines - 5),
    }, function(choice)
      if choice then
        vim.cmd("cd " .. vim.fn.fnameescape(choice))
        add_to_history(choice)
      end
    end)
  end
end

-- Nvim command to jump
vim.api.nvim_create_user_command("Z", function(args)
  jump(args.args)
end, { nargs = "?", complete = "dir" })

-- Automatically add current directory to history on VimEnter and DirChanged
vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
  callback = function()
    local current_dir = vim.fn.getcwd()
    -- Only add if not already in history
    if not path_in_history(current_dir) then
      add_to_history(current_dir)
    end
  end,
})

-- Load history on plugin load
load_history()

return M
