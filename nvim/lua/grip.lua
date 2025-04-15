-- ============================================================================
-- Markdown Preview Setup
-- ============================================================================

local function markdown_preview_toggle()
  -- Check if a preview is already running
  local handle = io.popen("pgrep -f 'grip.*6419' 2>/dev/null")
  local result = handle:read("*a")
  handle:close()

  if result ~= "" then
    -- Kill existing preview
    vim.fn.system("pkill -f 'grip.*6419'")
    print("Markdown preview stopped")
  else
    -- Start new preview
    local file = vim.fn.expand("%:p")
    local port = "6419"
    local cmd = string.format("grip '%s' --quiet --title='Neovim Preview' %s &", file, port)
    vim.fn.system(cmd)
    vim.fn.system(string.format("xdg-open http://localhost:%s 2>/dev/null &", port))  -- Linux/macOS
    -- For Windows, replace with:
    -- vim.fn.system("start http://localhost:" .. port)
    
    print("Markdown preview started at http://localhost:" .. port)
    
    -- Auto-kill on Neovim exit
    vim.api.nvim_create_autocmd("VimLeave", {
      callback = function()
        vim.fn.system("pkill -f 'grip.*6419'")
      end
    })
  end
end

-- Glow in floating terminal
local function glow_preview()
  local file = vim.fn.expand("%:p")
  vim.cmd("vsplit | terminal glow " .. file)
  vim.cmd("startinsert")
end

-- Frogmouth in floating terminal
local function frogmouth_preview()
  local file = vim.fn.expand("%:p")
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = math.min(80, vim.o.columns - 10),
    height = math.min(25, vim.o.lines - 10),
    col = (vim.o.columns - 80) / 2,
    row = (vim.o.lines - 25) / 2,
    style = "minimal",
    border = "rounded",
  })
  vim.fn.termopen("frogmouth " .. file)
  vim.cmd("startinsert")
end

-- Keymaps
vim.keymap.set("n", "<leader>mp", markdown_preview_toggle, { desc = "Toggle Markdown Preview (Browser)" })
vim.keymap.set("n", "<leader>mg", glow_preview, { desc = "Glow Preview (Terminal)" })
vim.keymap.set("n", "<leader>mf", frogmouth_preview, { desc = "Frogmouth Preview (Terminal)" })

-- Auto-format Markdown on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.md",
  callback = function()
    vim.cmd("silent! !prettier --write %")
    vim.cmd("edit!")  -- Reload the file
  end
})

-- Syntax highlighting for code blocks
vim.g.markdown_fenced_languages = {
  "python", "lua", "bash=sh", "javascript", "typescript", "html", "css"
}
