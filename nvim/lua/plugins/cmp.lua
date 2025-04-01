-- plugins/my_autocomplete.lua

local M = {}

local current_completions = {}
local current_prefix = ""
local current_index = 1

local function get_words_from_buffer()
  local words = {}
  for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    for word in line:gmatch("%w+") do
      words[word] = true
    end
  end
  return vim.tbl_keys(words)
end

local function get_words_from_files()
  local words = {}
  local current_dir = vim.fn.getcwd()
  local files = vim.fn.readdir(current_dir)
  if files then
    for _, file in ipairs(files) do
      words[file] = true
    end
  end
  return vim.tbl_keys(words)
end

local function get_words_from_lsp()
    local words = {}
    if vim.lsp.get_active_clients() ~= nil then
        for _, client in ipairs(vim.lsp.get_active_clients()) do
            if client.server_capabilities.completionProvider ~= nil then
                local params = vim.lsp.util.make_text_document_params()
                params.position = vim.lsp.util.offset_to_position(vim.api.nvim_get_current_buf(), vim.api.nvim_win_get_cursor(0)[1], vim.api.nvim_win_get_cursor(0)[2])
                client.request("textDocument/completion", params, function(err, result, ctx)
                    if result then
                        for _, item in ipairs(result.items) do
                            words[item.label] = true
                        end
                    end
                end)
            end
        end
    end
    return vim.tbl_keys(words)
end

local function get_completions(prefix)
  local words = {}
  for _, word in ipairs(get_words_from_buffer()) do
    table.insert(words, word)
  end

  for _, word in ipairs(get_words_from_files()) do
    table.insert(words, word)
  end

  for _, word in ipairs(get_words_from_lsp()) do
    table.insert(words, word)
  end

  local completions = {}
  for _, word in ipairs(words) do
    if word:sub(1, #prefix) == prefix then
      table.insert(completions, word)
    end
  end
  return completions
end

local function complete()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  current_prefix = line:sub(1, col)
  current_completions = get_completions(current_prefix)
  current_index = 1

  if #current_completions > 0 then
    vim.ui.select(current_completions, { prompt = "Autocomplete:" }, function(choice)
      if choice then
        local line_before_cursor = line:sub(1, col - #current_prefix)
        local line_after_cursor = line:sub(col + 1)
        vim.api.nvim_set_current_line(line_before_cursor .. choice .. line_after_cursor)
        vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], col - #current_prefix + #choice})
      end
    end)
  end
end

local function select_next()
  if #current_completions > 0 then
    current_index = (current_index % #current_completions) + 1
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line_before_cursor = line:sub(1, col - #current_prefix)
    local line_after_cursor = line:sub(col + 1)
    vim.api.nvim_set_current_line(line_before_cursor .. current_completions[current_index] .. line_after_cursor)
    vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], col - #current_prefix + #current_completions[current_index]:len()})
  end
end

local function select_prev()
  if #current_completions > 0 then
    current_index = (current_index - 2 + #current_completions) % #current_completions + 1
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line_before_cursor = line:sub(1, col - #current_prefix)
    local line_after_cursor = line:sub(col + 1)
    vim.api.nvim_set_current_line(line_before_cursor .. current_completions[current_index] .. line_after_cursor)
    vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], col - #current_prefix + #current_completions[current_index]:len()})
  end
end

M.setup = function()
  vim.keymap.set("i", "<C-Space>", complete)
  vim.keymap.set("i", "<C-n>", select_next)
  vim.keymap.set("i", "<C-p>", select_prev)
  vim.keymap.set("c","<C-Space>", complete)
  vim.keymap.set("c", "<C-n>", select_next)
  vim.keymap.set("c", "<C-p>", select_prev)
end

M.setup()

return M
