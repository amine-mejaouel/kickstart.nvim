return {
  'GustavEikaas/easy-dotnet.nvim',
  ft = { 'cs', 'fsharp', 'xml' },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    require('easy-dotnet').setup {
      picker = 'telescope',
      debugger = {
        auto_register_dap = true,
      },
    }
  end,
}
