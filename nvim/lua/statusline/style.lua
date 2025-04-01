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
-- modification
vim.opt.laststatus = 2
vim.opt.ruler = true

-- style
vim.opt.statusline = "Him[%f] %= %#LineNr# %y %p%% %#StatusLineMode#" .. get_git_branch() .. get_git_status() ..  "%#StatusLine# [%L:%c]"

