-- finder.lua

local M = {}

local function find_files(opts)
  opts = opts or {}
  local cwd = opts.cwd or vim.fn.getcwd()
  local pattern = opts.pattern or "*"
  local hidden = opts.hidden or false

  local files = {}
  local cmd = "find " .. vim.fn.escape(cwd, " ") .. " -type f"
  if not hidden then
    cmd = cmd .. " -not -path '*/\\.*'"
  end
  cmd = cmd .. " -name '" .. pattern .. "'"

  local handle = io.popen(cmd)
  if handle then
    for line in handle:lines() do
      table.insert(files, line)
    end
    handle:close()
  end
  return files
end

local function display_results(results, opts)
  opts = opts or {}
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, #results, false, results)

  local winnr = vim.api.nvim_open_win(bufnr, false, {
    relative = "editor",
    width = opts.width or 80,
    height = opts.height or 20,
    row = math.floor((vim.o.lines - (opts.height or 20)) / 2),
    col = math.floor((vim.o.columns - (opts.width or 80)) / 2),
  })

  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
  vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "delete")
  vim.api.nvim_buf_set_option(bufnr, "filetype", "finder")

  local function select_result()
    local line = vim.api.nvim_win_get_cursor(winnr)[1]
    local file_path = results[line]
    vim.api.nvim_win_close(winnr, false)
    vim.cmd("edit " .. vim.fn.escape(file_path, "%#"))
  end

  vim.api.nvim_buf_set_keymap(bufnr, "n", "<CR>", ":lua require('finder').select_result()<CR>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<Esc>", ":q<CR>", { noremap = true, silent = true })

  M.select_result = select_result

  return winnr
end

function M.find_files_and_display(opts)
  vim.ui.input({ prompt = "Find files: ", default = "*" }, function(input)
    if input then
      local results = find_files({ pattern = input, hidden = opts and opts.hidden })
      display_results(results, opts)
    end
  end)
end

return M
