-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

local function set_indent(filetype, shiftwidth, expandtab)
  vim.api.nvim_create_autocmd('FileType', {
    pattern = filetype,
    callback = function()
      vim.opt_local.shiftwidth = shiftwidth
      vim.opt_local.tabstop = shiftwidth
      vim.opt_local.expandtab = expandtab
    end,
  })
end

set_indent('sh', 2, true)
set_indent('ps1', 2, true)
