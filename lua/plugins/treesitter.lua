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
        -- `get_lang` falls back to the filetype itself, so this is never nil:
        -- plugin filetypes (lazy, oil, TelescopePrompt, ...) land here too.
        local lang = vim.treesitter.language.get_lang(args.match)

        local function start()
          -- Re-checked here: with an async install the buffer may be gone and
          -- the parser may have failed to build by the time this runs.
          if not vim.api.nvim_buf_is_valid(args.buf) or not vim.treesitter.language.add(lang) then
            return
          end
          vim.treesitter.start(args.buf, lang)
          if lang ~= 'ruby' then -- ruby indents better with vim's regex engine
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end

        if vim.treesitter.language.add(lang) then
          start()
        elseif vim.list_contains(ts.get_available(), lang) then
          -- Replaces the old `auto_install = true`. A failed install just leaves
          -- `start` a no-op; `install` reports that as a return value, not an error.
          ts.install(lang):await(vim.schedule_wrap(start))
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
