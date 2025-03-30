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

-- Add directory to history
local function add_to_history(dir)
  local found = false
  for i, d in ipairs(history) do
    if d == dir then
      found = true
      -- Move to the front of the list
      table.remove(history, i)
      table.insert(history, 1, dir)
      break
    end
  end

  if not found then
    table.insert(history, 1, dir)
  end

  -- Limit history size (e.g., to 100 entries)
  if #history > 100 then
    table.remove(history, #history)
  end
  save_history()
end

-- Fuzzy find and jump
local function jump(query)
  print("Query: " .. query) -- Inspect the query
  local results = {}
  for _, dir in ipairs(history) do
    if vim.fn.match(dir, query) ~= -1 then
      table.insert(results, dir)
    end
  end

  print(vim.inspect(results)) -- Inspect fuzzy finding results

  if #results == 0 then
    local expanded_query = vim.fn.expand(query)
    print("Expanded Query: " .. expanded_query) -- Inspect the expanded query
    if vim.fn.isdirectory(expanded_query) == 1 then
      vim.cmd("cd " .. vim.fn.shellescape(expanded_query))
      add_to_history(expanded_query)
    else
      vim.notify("No matching directories found in history or as a direct directory.", vim.log.levels.WARN)
    end
    return
  end

  if #results == 1 then
    local expanded_path = vim.fn.expand(results[1])
    if vim.fn.isdirectory(expanded_path) == 1 then
      vim.cmd("cd " .. vim.fn.shellescape(expanded_path))
      add_to_history(expanded_path)
    else
      vim.notify("Invalid directory: " .. expanded_path, vim.log.levels.ERROR)
    end
  else
    vim.ui.select(results, { prompt = "Select directory to jump to:" }, function(choice)
      if choice then
        local expanded_path = vim.fn.expand(choice)
        if vim.fn.isdirectory(expanded_path) == 1 then
          vim.cmd("cd " .. vim.fn.shellescape(expanded_path))
          add_to_history(expanded_path)
        else
          vim.notify("Invalid directory: " .. expanded_path, vim.log.levels.ERROR)
        end
      end
    end)
  end
end

-- Nvim command to jump
vim.api.nvim_create_user_command("Z", function(args)
  jump(args.fargs[1] or "")
end, { nargs = "?" })

-- Automatically add current directory to history on VimEnter and DirChanged
vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
  callback = function()
    local current_dir = vim.fn.getcwd()
    add_to_history(current_dir)
  end,
})

-- Load history on plugin load
load_history()

return M
