-- init.lua
vim.o.completeopt = "menu,menuone,noselect"

local M = {}

-- Table to store sources
M.sources = {}

-- Function to register sources
function M.register_source(name, source)
    M.sources[name] = source
end

-- Function to get completion items
function M.get_completions(prefix)
    local items = {}
    for _, source in pairs(M.sources) do
        local completions = source(prefix)
        if completions then
            for _, item in ipairs(completions) do
                table.insert(items, item)
            end
        end
    end
    return items
end

-- Function to setup key mappings
function M.setup()
    vim.api.nvim_set_keymap('i', '<C-Space>', 'v:lua.require"mycmp".complete()', {expr = true, noremap = true})
end

-- Function to trigger completion
function M.complete()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local prefix = line:sub(1, col):match("%S+$") or ""
    
    local items = M.get_completions(prefix)
    if #items > 0 then
        vim.fn.complete(col + 1, items)
    end
end

return M
