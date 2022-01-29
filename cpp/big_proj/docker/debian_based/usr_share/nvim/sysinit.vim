""" tabs and other style choices
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab

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
" LSP configuration
	Plug 'neovim/nvim-lspconfig'

" Treesitter
	Plug 'nvim-treesitter/nvim-treesitter'

" Telescope, a searching interface
	Plug 'nvim-lua/plenary.nvim'
	Plug 'nvim-telescope/telescope.nvim'

" Fugitive, git integration
        Plug 'tpope/vim-fugitive'

" Gitsigns, git in the statusline
        Plug 'lewis6991/gitsigns.nvim'
call plug#end()

if !empty($NVIM_PLUGIN_BOOTSTRAP)
	finish
endif

lua << EOF

        -- Fugitive

        local opts = { noremap = true, silent = true }
	vim.api.nvim_set_keymap('n', '<leader>gb', ':Git blame<CR>', opts)

	-- Telescope
	-- require('telescope').load_extension 'fzf'

	local opts = { noremap = true, silent = true}
	vim.api.nvim_set_keymap('n', '<leader>ff', [[<cmd>lua require('telescope.builtin').find_files()<CR>]], opts)
	vim.api.nvim_set_keymap('n', '<leader>fg', [[<cmd>lua require('telescope.builtin').live_grep()<CR>]], opts)
	vim.api.nvim_set_keymap('n', '<leader>fb', [[<cmd>lua require('telescope.builtin').buffers()<CR>]], opts)
	vim.api.nvim_set_keymap('n', '<leader>fh', [[<cmd>lua require('telescope.builtin').help_tags()<CR>]], opts)


	-- Treesitter
	-- TODO: configure folds etc.
	require('nvim-treesitter.install').compilers = { 'clang++' }


	-- LSP
	-- TODO: think about integrating with telescope (https://github.com/nvim-telescope/telescope.nvim#neovim-lsp-pickers)
	local on_attach = function(client, bufnr)
		local opts = { noremap = true, silent = true}
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
                vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>so', [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]], opts)
		vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>q', [[<cmd>lua require('lsp_code_action_no_menu')()<CR>]], opts)

	end

	require('lspconfig').clangd.setup{
		on_attach = on_attach
	}
EOF
