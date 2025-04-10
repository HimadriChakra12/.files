-- plugins/error_popup.lua

local M = {}

local popup_id = nil
local error_lines = {}

local function clear_popup()
  if popup_id and vim.api.nvim_win_is_valid(popup_id) then
    vim.api.nvim_win_close(popup_id, false)
    popup_id = nil
  end
  error_lines = {}
end

local function create_popup()
  if #error_lines == 0 then
    clear_popup()
    return
  end

  local lines = {}
  for _, err in ipairs(error_lines) do
    table.insert(lines, err.message)
  end

  local width = 40 -- Adjust width as needed
  local height = #lines
  local row = 0    -- Always at the top
  local col = 0    -- Always at the left

  local border_chars = { "│", "─", "│", "─", "┌", "┐", "┘", "└" }

  local opts = {
    relative = "editor",
    anchor = "NW",
    row = row,
    col = col,
    width = width,
    height = height,
    border = border_chars,
    focusable = false,
    style = "minimal",
  }

  popup_id = vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), false, opts)
  vim.api.nvim_buf_set_lines(popup_id, 0, -1, false, lines)

  -- Set buffer options for read-only and no line numbers
  vim.api.nvim_buf_set_option(popup_id, "modifiable", false)
  vim.api.nvim_buf_set_option(popup_id, "number", false)
  vim.api.nvim_buf_set_option(popup_id, "relativenumber", false)
end

function M.show_errors(errors)
  clear_popup()
  if errors and #errors > 0 then
    error_lines = errors
    create_popup()
  end
end

function M.clear_errors()
  clear_popup()
end

return M
