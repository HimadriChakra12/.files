-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'
    
    use {
	    'vzze/cmdline.nvim',
	    config = function()
		    require('cmdline').setup({
			    cmdtype = ":/", -- you can also add / and ? by using ":/?"
			    -- as a string

			    window = {
				    matchFuzzy = true,
				    offset     = 1,    -- depending on 'cmdheight' you might need to offset
				    debounceMs = 10    -- the lower the number the more responsive however
				    -- more resource intensive
			    },

			    hl = {
				    default   = "Pmenu",
				    selection = "PmenuSel",
				    directory = "Directory",
				    substr    = "LineNr"
			    },

			    column = {
				    maxNumber = 6,
				    minWidth  = 20
			    },

			    binds = {
				    next = "<Tab>",
				    back = "<S-Tab>"
			    }
		    })
	    end
    }
  
    use 'folke/flash.nvim'

    use {
        'xsoder/buffer-manager',
        requires = {
            'MunifTanjim/nui.nvim',
            'nvim-tree/nvim-web-devicons', -- optional
            'ibhagwan/fzf-lua', -- optional
        },
        config = function()
            require("buffer-manager")
        end
    }
    -- Simple plugins can be specified as strings
    use 'rstacruz/vim-closer'

    use {
        'xsoder/NeoGit',
        requires = {
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope.nvim', -- Optional, for enhanced file picking
        }
    }

    -- Lazy loading:
    -- Load on specific commands
    use {'tpope/vim-dispatch', opt = true, cmd = {'Dispatch', 'Make', 'Focus', 'Start'}}

    -- Load on an autocommand event
    use {'andymass/vim-matchup', event = 'VimEnter'}

    -- Load on a combination of conditions: specific filetypes or commands
    -- Also run code after load (see the "config" key)
    use {
        'w0rp/ale',
        ft = {'sh', 'zsh', 'bash', 'c', 'cpp', 'cmake', 'html', 'markdown', 'racket', 'vim', 'tex'},
        cmd = 'ALEEnable',
        config = 'vim.cmd[[ALEEnable]]'
    }

    -- Plugins can have dependencies on other plugins
    use {
        'haorenW1025/completion-nvim',
        opt = true,
        requires = {{'hrsh7th/vim-vsnip', opt = true}, {'hrsh7th/vim-vsnip-integ', opt = true}}
    }

    -- Plugins can also depend on rocks from luarocks.org:

    -- Post-install/update hook with neovim command
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

    -- Post-install/update hook with call of vimscript function with argument
    use { 'glacambre/firenvim', run = function() vim.fn['firenvim#install'](0) end }

    -- Use dependency and run lua function after load
    use {
        'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' },
        config = function() require('gitsigns').setup() end
    }

    -- You can specify multiple plugins in a single call

    -- You can alias plugin names
    use {'dracula/vim', as = 'dracula'}
end)
