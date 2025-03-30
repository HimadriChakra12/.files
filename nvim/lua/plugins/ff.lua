-- fzf-based file search plugin (with terminal clearing)

local M = {}

local function find_files_fzf(query)
  local fzf_command = "find . -type f | fzf --query='" .. query .. "'"
  local files = vim.fn.systemlist(fzf_command)
  return files
end

local function search_and_open_fzf(query)
  vim.cmd("silent !clear") -- Clear the terminal
  local files = find_files_fzf(query)

  if #files == 0 then
    vim.notify("No matching files found.", vim.log.levels.WARN)
    return
  end

  if #files == 1 then
    vim.cmd("edit " .. vim.fn.shellescape(files[1]))
  else
    vim.ui.select(files, { prompt = "Select file to open:" }, function(choice)
      if choice then
        vim.cmd("edit " .. vim.fn.shellescape(choice))
      end
    end)
  end
end

vim.api.nvim_create_user_command("Ffind", function(args)
  search_and_open_fzf(args.fargs[1] or "")
end, { nargs = "?" })

return M
