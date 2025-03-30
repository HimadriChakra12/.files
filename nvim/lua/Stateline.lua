-- Minimal Statusline
vim.o.statusline = "%m%% %r %= %y %p%% %l:%c"

-- Mode

function mode_color()
    local mode = vim.api.nvim_get_mode().mode
    local mode_map = {
        n = "NORMAL",
        i = "INSERT",
        v = "VISUAL",
        V = "V-LINE",
        c = "COMMAND",
        R = "REPLACE"
    }
    return mode_map[mode] or mode
end

-- Colorize

vim.o.statusline = "%#PmenuSel#" .. mode_color() .. " %#LineNr# %f %m %= %y %p%% %l:%c"

vim.opt.laststatus = 2
vim.opt.showmode = false  -- Hide "-- INSERT --" since the status line will show it
vim.opt.ruler = true

