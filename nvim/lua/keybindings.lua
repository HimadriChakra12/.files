-- Quality-of-Life Keybindings
vim.g.mapleader = " "  -- Set leader key to Space

local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Better window movement
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)
keymap("n", "<leader>w", ":bd<CR>", opts)

-- Fast saving & quitting
-- keymap("n", "<Leader>w", ":w<CR>", opts)
-- keymap("n", "<Leader>qq", ":q!<CR>", opts)
keymap("n", "<Leader>x", ":x<CR>", opts)


vim.keymap.set('n', '<leader>e', '<cmd>Explorer<cr>')
vim.keymap.set('n', '<leader>n', ':enew<CR>', { noremap = true, silent = true })
vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>", { noremap = true, silent = true })

-- vim.api.nvim_set_keymap("n", "<leader>ff", ":FF<CR>", { noremap = true, silent = true })
vim.keymap.set('n', '<leader><leader>', ':Telescope find_files<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>g', ':Telescope live_grep<CR>')
vim.keymap.set('n', '<leader><tab>', '<cmd>Telescope buffers<cr>', { desc = 'Find existing buffers' })

vim.keymap.set("n", "<leader>z", ":Zcd ", { noremap = true})
vim.keymap.set("n", "<leader><leader>z", ":Zt<CR>", { noremap = true, silent = true })
-- Option 1: Mapping to Clear Highlighting (e.g., <CR> after search)
vim.api.nvim_set_keymap('n', '<CR>', ':noh<CR>', { noremap = true, silent = true })

-- Option 2: Mapping to a Specific Key (e.g., <Esc> twice)
vim.api.nvim_set_keymap('n', '<Esc><Esc>', ':noh<CR>', { noremap = true, silent = true })

-- Option 3: Mapping to a Custom Key (e.g., <Leader>h)
vim.api.nvim_set_keymap('n', '<Leader>h', ':noh<CR>', { noremap = true, silent = true })

-- Option 4: Using an Autocommand
vim.api.nvim_create_autocmd("CmdlineLeave", {
  pattern = "*",
  command = "noh",
})

-- Keybindings configuration
vim.keymap.set('n', '<leader><CR>', ':TerminalPopup<CR>', {silent = true, desc = 'Toggle Terminal Popup' })
