local buffer = require('buffer')

-- git indicator
local function is_git_repo()
  local git_dir = vim.fn.finddir(".git", ";")
  return git_dir ~= ""
end

local function get_git_branch()
  if is_git_repo() then
      local branch = vim.fn.systemlist("git branch --show-current")[1]
      if branch and branch ~= "" then
        return " " .. branch
      else
        return ""
      end
  else
    return ""
  end
end
local function get_git_status()
  local status = vim.fn.systemlist("git status --porcelain")[1]
  if status and status ~= "" then
    return " " --  is a git status icon
  else
    return ""
  end
end
-- git 


-- style
-- [v] vim.opt.statusline = "Him[%f] %= %#LineNr# %y %p%% %#StatusLineMode#" .. get_git_branch() .. get_git_status() ..  "%#StatusLine# [%L:%c]"
-- [v] vim.opt.statusline = "%{toupper(mode())}[%f] %=%{luaeval('get_buffers()')}%= %#LineNr# %y %p%% %#StatusLineMode#%{get(g:, 'get_git_branch', '')}%{get(g:, 'get_git_status', '')}%#StatusLine# [%L:%c]"
-- [x] vim.opt.statusline = "%{%v:lua.get_mode()%}[%f] %=%{luaeval('get_buffers()')}%= %#LineNr# %y %p%% %#StatusLineMode#%{get(g:, 'get_git_branch', '')}%{get(g:, 'get_git_status', '')}%#StatusLine# [%L:%c]"

-- Buffers
vim.opt.statusline = "# %{toupper(mode())} # %{luaeval('get_buffers()')}%= |%#LineNr# %m  %y %p%% %#StatusLineMode#" .. get_git_branch() .. get_git_status() ..  " %#StatusLine# [%L:%c]"
