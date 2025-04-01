local function create_floating_window()
    local width = math.floor(vim.o.columns * 0.6)
    local height = math.floor(vim.o.lines * 0.6)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    -- Create a scratch buffer
    local buf = vim.api.nvim_create_buf(false, true)

    -- Set window options
    local opts = {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
    }

    -- Open a floating window
    local win = vim.api.nvim_open_win(buf, true, opts)
    return buf, win
end

local function fuzzy_find()
    local buf, win = create_floating_window()
    vim.api.nvim_buf_set_option(buf, "buftype", "prompt")

    -- Run `find` (Linux/macOS) or `dir /b /s` (Windows) to get file list
    local cmd = vim.fn.has("win32") == 1 and "dir /b /s" or "find . -type f"
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    handle:close()

    -- Split result into lines
    local files = {}
    for line in result:gmatch("[^\r\n]+") do
        table.insert(files, line)
    end

    -- Insert files into buffer
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, files)

    -- Function to open selected file
    local function open_selected_file()
        local cursor_pos = vim.api.nvim_win_get_cursor(win)[1]
        local selected_file = files[cursor_pos]
        vim.api.nvim_win_close(win, true)  -- Close floating window
        vim.cmd("edit " .. selected_file)  -- Open file
    end

    -- Keybindings
    vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", ":lua open_selected_file()<CR>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q!<CR>", { noremap = true, silent = true }) -- Quit

    -- Message for usage
    print("Use arrow keys or j/k to navigate. Press <Enter> to open a file.")
end

-- 🔥 Keybind: Press `<Leader>f` to Open Fuzzy Finder
vim.api.nvim_set_keymap("n", "<leader>tf", ":lua fuzzy_find()<CR>", { noremap = true, silent = true })
