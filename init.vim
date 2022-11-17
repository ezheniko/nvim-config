call plug#begin('~/.config/nvim/plugged')
    Plug 'neovim/nvim-lspconfig'
    Plug 'hrsh7th/nvim-cmp'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'hrsh7th/cmp-buffer'
    Plug 'hrsh7th/cmp-path'
    " Plug 'hrsh7th/cmp-cmdline'
    Plug 'saadparwaiz1/cmp_luasnip'
    Plug 'L3MON4D3/LuaSnip'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'
    Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'tami5/lspsaga.nvim'
    Plug 'nvim-lualine/lualine.nvim'
    Plug 'tpope/vim-fugitive'
    Plug 'numToStr/Comment.nvim'
    " themes
    Plug 'arcticicestudio/nord-vim'
    Plug 'w0ng/vim-hybrid'
    Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
    Plug 'sainnhe/everforest'
    Plug 'morhetz/gruvbox'
    Plug 'ghifarit53/daycula-vim', { 'branch': 'main' }
    Plug 'hachy/eva01.vim'
call plug#end()

syntax on
set noswapfile
set number
set relativenumber
"set guicursor=
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set scrolloff=6
set smartindent

set nohlsearch

set nowrap

set signcolumn=yes
"set colorcolumn=70

set laststatus=3 "global statusline
set winbar=%=%m\ %f

set termguicolors
"colorscheme nord
"colorscheme hybrid
"colorscheme tokyonight
"colorscheme everforest
colorscheme gruvbox
"colorscheme daycula
"colorscheme eva01

let mapleader = ' '

lua << EOF
--local capabilities = vim.lsp.protocol.make_client_capabilities()
--capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
--
---- Enable some language servers with the additional completion capabilities offered by nvim-cmp
--local servers = { 'eslint',  'tsserver' }
--for _, lsp in ipairs(servers) do
--  nvim_lsp[lsp].setup {
--    -- on_attach = my_custom_on_attach,
--    capabilities = capabilities,
--  }
--end

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- luasnip setup
local luasnip = require 'luasnip'

-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}
EOF


lua << EOF
local nvim_lsp = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  --buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

  end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'eslint', 'tsserver' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
end
EOF

lua << EOF
local saga = require('lspsaga')
saga.init_lsp_saga {
    warn_sign = '⚠',
    infor_sign = '🛈',
    error_sign = '⊗',
    hint_sign = '🢒',
}
EOF

lua << EOF
require'nvim-treesitter.configs'.setup {
    highlight = {
        enable = true,
        disable = {},
    },
    indent = {
        enable = false,
        disable = {},
    },
    ensure_installed = {
        "html",
        "css",
        "scss",
        "json",
        "javascript",
        "typescript",
        "tsx",
    }
}
EOF

lua << EOF
require('Comment').setup()
EOF

lua << EOF
require('lualine').setup {
    options = {
        section_separators = '',
        component_separators = '',
    },
    sections = {
        lualine_a = {'mode'},
        lualine_b = {
            {
                'diagnostics',
                symbols = {error = '⊗ ', warn = '⚠ ', info = '🛈 ', hint = 'H'},
            }
        },
        lualine_c = {
            {
                'filename',
                path = 1
            }
        },
        lualine_x = {'encoding'},
        lualine_y = {''},
        lualine_z = {'location'},
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
            {
                'filename',
                path = 1
            }
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {'location'},
    }
}
EOF

lua << EOF
require('telescope').setup {
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    }
  }
}

require('telescope').load_extension('fzf')
EOF

nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fw :execute 'Telescope live_grep default_text=' . expand('<cword>')<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

nnoremap <silent> [e :Lspsaga diagnostic_jump_next<CR>
nnoremap <silent> ]e :Lspsaga diagnostic_jump_prev<CR>
nnoremap <silent> gh :Lspsaga lsp_finder<CR>
nnoremap <silent>K :Lspsaga hover_doc<CR>
nnoremap <silent> gs :Lspsaga signature_help<CR>
nnoremap <silent><space>rn :Lspsaga rename<CR>

