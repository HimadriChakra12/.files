-- /lua/..
require('keybindings')
require('netwr')
-- /pack/..
require('telescope').setup{}
require('yazi').setup()
require('packer.packer')

require("buffer-manager").setup({
    icons = true,
    use_devicons = true,
    default_mappings = true,
    window = {
        width = 0.5,
        height = 0.6,
        border = "rounded",
        preview_width = 0.5,
    },
    style = {
        numbers = "ordinal", -- or "none"
        modified_icon = "●",
        current_icon = "",
        path_style = "shorten", -- "filename", "relative", "absolute", "shorten"
    },
    mappings = {
        open = "<leader><leader>",
        vertical = "<leader>bv",
        horizontal = "<leader>bs",
        delete = "<leader>bd",
        delete_force = "<leader>bD",
    },
    sessions = {
        enabled = false,
        auto_save = false,
        session_dir = vim.fn.stdpath("data") .. "/buffer-manager-sessions",
        session_file = "session.json",
        indicator_icon = "󱡅",
    },
    preview = {
        enabled = true,
        type = "lf",
    }
})
-- /lua/statusline..
require("status.theme")
require("status.style")

require("startups.startup4")
require("startups.startup1")
-- /lua/plugins..
require("plugins.shell")
require('plugins.pcmp').setup()
require("plugins.bufshift")
-- require("plugins.tree") --[Replaced with explorer.lua]
require("plugins.explo")
require("plugins.zox").setup() 
require("plugins.termim") 

-- require("plugins.zoxvim").setup() --[Replaced with zox.lua]
-- require("plugins.ff") [Replaced by telescope.nvim]
-- require("plugins.explorer")
-- require("scope").setup() [Replaced with telescope.nvim]
-- vim.keymap.set("n", "<leader>cd", require("telescope").extensions.zoxide.list)

-- Line Numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.fillchars = { eob = " " }

-- Better searching
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true  -- Makes search case-sensitive if uppercase letters are used


-- Faster Keypress
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500

-- Tabs and Indent
vim.opt.expandtab = true  -- Convert tabs to spaces
vim.opt.tabstop = 4       -- Number of spaces a tab counts for
vim.opt.shiftwidth = 4    -- Number of spaces for autoindent
vim.opt.softtabstop = 4
vim.opt.autoindent = true
vim.opt.smartindent = true

-- No Annoy
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

-- Yanked Text
vim.cmd [[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank { higroup="IncSearch", timeout=200 }
  augroup END
]]

-- TP BG
-- vim.cmd([[highlight Normal guibg=NONE ctermbg=NONE]])
-- vim.cmd([[highlight NonText guibg=NONE ctermbg=NONE]])
-- vim.cmd([[highlight NormalNC guibg=NONE ctermbg=NONE]])
-- vim.cmd([[highlight EndOfBuffer guibg=NONE ctermbg=NONE]])

vim.opt.termguicolors = true  -- Enable 24-bit colors
vim.opt.background = "dark"   -- Set to dark mode
vim.cmd("colorscheme gruvbox")  -- Load Gruvbox


