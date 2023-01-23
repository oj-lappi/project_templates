""" tabs and other style choices
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab

""" treat .tpp files as cpp files
autocmd BufEnter *.tpp :setlocal filetype=cpp


""" clang-format
"function! Formatonsave()
"  let l:formatdiff = 1
"  py3f /usr/share/vim/addons/syntax/clang-format.py
"endfunction
"autocmd BufWritePre *.h,*.cc,*.cpp call Formatonsave()
"""

let mapleader = " "

""" Plugins
call plug#begin( '/usr/share/nvim/plugged' )

" Helpers
" vim-rooter, find parent dir based on patterns
	Plug 'airblade/vim-rooter'

" Fugitive, git integration
        Plug 'tpope/vim-fugitive'

" Gitsigns, git in the statusline
        Plug 'lewis6991/gitsigns.nvim'

" Telescope, a searching interface
	Plug 'nvim-lua/plenary.nvim'
        Plug 'nvim-telescope/telescope.nvim', { 'tag': 'nvim-0.6'}
	"Plug 'nvim-telescope/telescope-fzf-native.nvim'
	"
" Treesitter
"	Plug 'nvim-treesitter/nvim-treesitter', { 'branch': '0.5-compat'}

" LSP configuration
	Plug 'neovim/nvim-lspconfig'

" nvim-cmp, autocompletion
        Plug 'hrsh7th/cmp-nvim-lsp'
        Plug 'hrsh7th/cmp-buffer'
        Plug 'hrsh7th/cmp-path'
        Plug 'hrsh7th/cmp-cmdline'
        Plug 'hrsh7th/nvim-cmp', {'commit': '4f1358e659d51c69055ac935e618b684cf4f1429'}

" vsnip, snippets (used by nvim-cmp)
        Plug 'hrsh7th/cmp-vsnip'
        Plug 'hrsh7th/vim-vsnip'

call plug#end()

if !empty($NVIM_PLUGIN_BOOTSTRAP)
	finish
endif


lua << EOF
	-- default opts
        local opts = { noremap = true, silent = true }

	-- vim-rooter
        vim.g.rooter_patterns = { '.git', 'src', 'include' }

        -- Fugitive (git integration)

	vim.api.nvim_set_keymap('n', '<leader>gb', ':Git blame<CR>', opts)

	-- Telescope (finder)
	local telescope = require('telescope')
	-- require('telescope').load_extension 'fzf'


        function find_files_in_project()
            local opts = { noremap = true, silent = true, cwd = vim.fn.FindRootDirectory() }
            require('telescope.builtin').find_files(opts)
	end

        vim.api.nvim_set_keymap('n', '<leader>ff', [[<cmd>lua find_files_in_project()<CR>]], opts)
	vim.api.nvim_set_keymap('n', '<leader>fg', [[<cmd>lua require('telescope.builtin').live_grep()<CR>]], opts)
	vim.api.nvim_set_keymap('n', '<leader>fb', [[<cmd>lua require('telescope.builtin').buffers()<CR>]], opts)
	vim.api.nvim_set_keymap('n', '<leader>fh', [[<cmd>lua require('telescope.builtin').help_tags()<CR>]], opts)

	-- Treesitter
	-- TODO: configure folds etc.
        -- disabled for now, see Plug line
        -- require('nvim-treesitter.install').compilers = { 'clang++' }

        -- snippets

        --imap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'
        --smap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'
        vim.api.nvim_set_keymap('i', '<C-j>', [[vsnip#expandable() ? '<Plug>(vsnip-expand)']], opts)
        vim.api.nvim_set_keymap('s', '<C-j>', [[vsnip#expandable() ? '<Plug>(vsnip-expand)']], opts)

        --imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
        --smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
        vim.api.nvim_set_keymap('i', '<C-l>', [[vsnip#available() ? '<Plug>(vsnip-expand-or-jump)']], opts)
        vim.api.nvim_set_keymap('s', '<C-l>', [[vsnip#available() ? '<Plug>(vsnip-expand-or-jump)']], opts)

        --" Jump forward or backward
        --imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
        --smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
        --imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
        --smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

        --nmap        s   <Plug>(vsnip-select-text)
        --xmap        s   <Plug>(vsnip-select-text)
        --nmap        S   <Plug>(vsnip-cut-text)
        --xmap        S   <Plug>(vsnip-cut-text)

        -- cmp, autocompletion
        -- still needs setup, is a little useless at the moment
        local cmp = require('cmp')

        -- https://github.com/hrsh7th/nvim-cmp/README.md
        -- --[[
	-- main setup with lsp
        cmp.setup({
            snippet = {
              -- REQUIRED - you must specify a snippet engine
              expand = function(args)
                vim.fn["vsnip#anonymous"](args.body)
              end,
            },
            mapping = {
              ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
              ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
              ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
              ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
              ['<C-e>'] = cmp.mapping({
                i = cmp.mapping.abort(),
                c = cmp.mapping.close(),
              }),
              ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
            },
            sources = cmp.config.sources({
              { name = 'nvim_lsp' },
              -- { name = 'vsnip' },
	      -- vsnip disabled because it's suggesting questionable autocompletes
            }, {
              { name = 'buffer' },
            })
          })
        -- --]]
	-- main setup

          --[[
          -- Set configuration for specific filetype.
          cmp.setup.filetype('gitcommit', {
            sources = cmp.config.sources({
              { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
            }, {
              { name = 'buffer' },
            })
          })
          --]]

          --[[
          -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
          cmp.setup.cmdline('/', {
            sources = {
              { name = 'buffer' }
            }
          })
          --]]

          --[[
          -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
          cmp.setup.cmdline(':', {
            sources = cmp.config.sources({
              { name = 'path' }
            }, {
              { name = 'cmdline' }
            })
          })
          --]]
        --]]

	-- LSP
	-- TODO: think about integrating with telescope (https://github.com/nvim-telescope/telescope.nvim#neovim-lsp-pickers)
	local on_attach = function(client, bufnr)
		-- use omnifunc for completion (<C-x><C-o>)
		vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
		-- omnifunc is mutually exclusive with nvim-cmp

		vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
		vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
		vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
		vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
		vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
		vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
		vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
		vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
		vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
		vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
		vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
		vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)

		vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
		vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader><Left>', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
		vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader><Right>', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
		vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Tab><Left>', '<cmd>lua vim.diagnostic.goto_prev( { severity = vim.diagnostic.severity.ERROR } )<CR>', opts)
		vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Tab><Right>', '<cmd>lua vim.diagnostic.goto_next( { severity = vim.diagnostic.severity.ERROR } )<CR>', opts)
		vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>l', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
		vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>fmt', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

		-- These have dependencies
		-- immediate quickfix
		vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>q', [[<cmd>lua require('lsp_code_action_no_menu')()<CR>]], opts)

		-- telescope
                vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>so', [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]], opts)
		-- TODO: check if <leader>gr works for references. If not, think about using telescope.

	end

        -- Autocompletion

        local capabilities = require('cmp_nvim_lsp').default_capabilities()

	require('lspconfig').clangd.setup{
		on_attach = on_attach,
                capabilities = capabilities
	}
EOF
