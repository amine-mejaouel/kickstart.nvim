return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false, -- the main branch does not support lazy-loading
  build = ':TSUpdate',
  dependencies = { 'mason-org/mason.nvim' }, -- mason's setup prepends mason/bin (the tree-sitter shim) to $PATH
  -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
  config = function()
    local ts = require 'nvim-treesitter'

    -- Building a parser always shells out to `tree-sitter build`, and the CLI
    -- comes from mason-tool-installer, which only runs later on the first
    -- startup after a fresh clone. Skipping keeps that startup quiet; the
    -- parsers install on the next launch.
    local function have_cli()
      return vim.fn.executable 'tree-sitter' == 1
    end

    -- Installed eagerly (async; no-op when already up to date)
    if have_cli() then
      ts.install { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc', 'gitcommit' }
    end

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
          -- Ruby indents better with vim's regex engine, and only about half the
          -- parsers ship an `indents` query -- without one the treesitter
          -- indentexpr returns 0 for every line and would clobber vim's built-in
          -- indent (vim, vimdoc, gitcommit, diff, luadoc, markdown_inline).
          -- NOTE: the old config also set `additional_vim_regex_highlighting = { 'ruby' }`,
          -- which ruby's own indentexpr needs (it calls synID()). Dropped on
          -- purpose: there is no ruby in this setup.
          if lang ~= 'ruby' and vim.treesitter.query.get(lang, 'indents') then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end

        if vim.treesitter.language.add(lang) then
          start()
        elseif have_cli() and vim.list_contains(ts.get_available(), lang) then
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
