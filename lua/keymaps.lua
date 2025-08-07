--[[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights of previous search
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
-- 'n' means normal mode. Esc is the key pressed. <cmd> is the command executed. <CR> simulates enter.

-- Diagnostic keymaps
-- open a list of current errors and warnings in your code (if there is any)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- disables terminal mode and enters command mode
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- shortcuts to open terminal in neovim
vim.keymap.set('n', '<leader>tv', ':Tv<CR>', { desc = 'Terminal vertical split' })
vim.keymap.set('n', '<leader>th', ':Th<CR>', { desc = 'Terminal horizontal split' })

-------------------------------------------------------------------------------------------------------------------------------------

--[[ Basic Autocommands ]]
-- See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Trim trailing whitespace
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  callback = function()
    vim.cmd [[ %s/\s\+$//e ]]
  end,
})

-- Highlight current line in active split only
vim.api.nvim_create_autocmd({ 'WinEnter', 'BufWinEnter' }, {
  callback = function()
    vim.wo.cursorline = true
  end,
})
vim.api.nvim_create_autocmd({ 'WinLeave' }, {
  callback = function()
    vim.wo.cursorline = false
  end,
})

-- Proper syntax highlighting & indentation rules
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'javascript', 'typescript', 'css', 'lua', 'yaml' },
  group = vim.api.nvim_create_augroup('indent_settings', { clear = true }),
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,
})

-- Restore cursor position
vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto-reload file if it changed outside Neovim
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold' }, {
  callback = function()
    local mode = vim.fn.mode()
    if mode == 'c' or mode == 'i' then
      return
    end

    local buf = vim.api.nvim_get_current_buf()
    local modified = vim.api.nvim_buf_get_option(buf, 'modified')
    local modifiable = vim.api.nvim_buf_get_option(buf, 'modifiable')

    if not modifiable then
      return
    end

    -- Check if file changed on disk
    vim.cmd 'checktime'

    if modified then
      -- Check if the file has changed outside
      local file = vim.api.nvim_buf_get_name(buf)
      local stat = vim.loop.fs_stat(file)
      local changedtick = vim.b._last_reload_check or 0

      -- user promt to decide
      if stat and stat.mtime.sec ~= changedtick then
        local choice = vim.fn.confirm('File changed on disk. Reload and lose unsaved changes?', '&Yes\n&No', 2)
        if choice == 1 then
          vim.cmd 'edit!' -- Force reload, discards changes
          vim.notify('File reloaded from disk.', vim.log.levels.INFO)
        else
          vim.notify('Reload canceled. You still have unsaved changes.', vim.log.levels.WARN)
        end
      end
    end

    -- Store the current file modification time
    local stat = vim.loop.fs_stat(vim.api.nvim_buf_get_name(buf))
    if stat then
      vim.b._last_reload_check = stat.mtime.sec
    end
  end,
})

-- Custom command to open terminal in neovim
vim.api.nvim_create_user_command('Tv', 'vsplit | terminal', {
  desc = 'Open terminal in vertical split',
})

vim.api.nvim_create_user_command('Th', 'split | terminal', {
  desc = 'Open terminal in horizontal split',
})

-- Autocommand to enter insert mode on terminal open
vim.api.nvim_create_autocmd('TermOpen', {
  desc = 'Go to insert mode when terminal opens',
  callback = function()
    vim.cmd 'startinsert'
  end,
})

-- Disable auto-comment on new lines
vim.api.nvim_create_autocmd('BufEnter', {
  desc = 'Disable auto comment continuation',
  callback = function()
    vim.cmd [[setlocal formatoptions-=c formatoptions-=r formatoptions-=o]]
  end,
})
