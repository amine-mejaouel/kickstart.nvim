return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false, -- the main branch does not support lazy-loading
  build = ':TSUpdate',
  dependencies = { 'mason-org/mason.nvim' }, -- mason's setup puts tree-sitter-cli on Neovim's PATH first
  -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
  config = function()
    local ts = require 'nvim-treesitter'

    -- Installed eagerly (async; no-op when already up to date)
    ts.install { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc', 'gitcommit' }

    -- The main branch has no `highlight`/`indent` opts; both are enabled
    -- per-buffer via `vim.treesitter.start()` and 'indentexpr'.
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('kickstart-treesitter', { clear = true }),
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match)
        if not lang then
          return
        end

        local function start()
          vim.treesitter.start(args.buf, lang)
          if lang ~= 'ruby' then -- ruby indents better with vim's regex engine
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end

        if vim.treesitter.language.add(lang) then
          start()
        else
          -- Replaces the old `auto_install = true`
          ts.install(lang):await(function(err)
            if err or not vim.api.nvim_buf_is_valid(args.buf) then
              return
            end
            vim.schedule(start)
          end)
        end
      end,
    })
  end,
  -- There are additional nvim-treesitter modules that you can use to interact
  -- with nvim-treesitter. You should go explore a few and see what interests you:
  --
  --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
  --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
}
