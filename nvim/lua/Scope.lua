-- Basic fuzzy finder implementation
local M = {}

-- Function to fetch all files in the current working directory
local function get_files()
  local handle = io.popen("find . -type f 2>/dev/null") -- Avoid errors
  if not handle then return {} end
  local result = handle:read("*a")
  handle:close()
  return vim.split(result, "\n", { trimempty = true }) -- Remove empty entries
end

-- Function to display the picker UI
local function picker(items, prompt)
  if #items == 0 then
    print("No items found")
    return nil
  end

  local choice = vim.fn.input(prompt .. "\n" .. table.concat(items, "\n") .. "\n> ")
  if choice == "" then return nil end  -- Handle empty input

  for _, item in ipairs(items) do
    if item:find(choice, 1, true) then  -- Use plain text search
      return item
    end
  end
end

-- Function to open the selected file
function M.find_files()
  local files = get_files()
  local selected_file = picker(files, "Search Files:")
  if selected_file and selected_file ~= "" then
    vim.cmd("edit " .. vim.fn.fnameescape(selected_file))
  end
end

-- Function to list buffers and switch between them
function M.switch_buffer()
  local buffers = {}
  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buffer) then
      local name = vim.api.nvim_buf_get_name(buffer)
      if name and name ~= "" then
        table.insert(buffers, name)
      end
    end
  end
  
  local selected_buffer = picker(buffers, "Switch Buffer:")
  if selected_buffer and selected_buffer ~= "" then
    vim.cmd("buffer " .. vim.fn.bufnr(selected_buffer))
  end
end

-- Key mappings for convenience

return M
