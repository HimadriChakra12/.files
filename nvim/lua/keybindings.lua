-- Quality-of-Life Keybindings
vim.g.mapleader = " "  -- Set leader key to Space

local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Better window movement
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Fast saving & quitting
keymap("n", "<Leader>w", ":w<CR>", opts)
keymap("n", "<Leader>q", ":q!<CR>", opts)
keymap("n", "<Leader>x", ":x<CR>", opts)
vim.keymap.set('n', '<leader>n', ':enew<CR>', { noremap = true, silent = true })
vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>", { noremap = true, silent = true })
-- ... (Your existing statusline and buffer list code) ...

-- Keymap to manually trigger the statusline update
vim.keymap.set("n", "<leader>rs", function()
  vim.cmd("silent redrawstatus")
end, { desc = "Redraw Statusline" })

-- ... (Your existing autocommands and other keymaps) ...
