return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  config = function(_, opts)
    require('conform').setup(opts)
    -- https://github.com/JohnnyMorganz/StyLua/?tab=readme-ov-file#options
    require('conform').formatters.stylua = {
      append_args = { '--indent-type', 'Spaces', '--indent-width', '2' },
    }
  end,
  opts = {
    ensure_installed = { 'prettier' },
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = { c = true, cpp = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      else
        return {
          timeout_ms = 500,
          lsp_format = 'fallback',
        }
      end
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      rust = { 'rustfmt' },
      json = { 'prettier', 'json-format' },
      jsonc = { 'prettier', 'json-format' },
      css = { 'prettier' },
      xml = { 'xmlformatter' },
      -- Conform can also run multiple formatters sequentially
      -- python = { "isort", "black" },
      --
      -- You can use 'stop_after_first' to run the first available formatter from the list
      -- javascript = { "prettierd", "prettier", stop_after_first = true },
    },
  },
}
