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
keymap("n", "<Leader>q", ":q<CR>", opts)
keymap("n", "<Leader>x", ":x<CR>", opts)
