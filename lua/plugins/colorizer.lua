return {
  'norcalli/nvim-colorizer.lua',
  config = function()
    require('colorizer').setup {
      'css',
    }
  end,
}
