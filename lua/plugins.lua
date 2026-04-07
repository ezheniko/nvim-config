local gh = function(x) return 'https://github.com/' .. x end

-- Helper to shorten GitHub URLs
vim.pack.add({
    -- Colorscheme
    gh('rebelot/kanagawa.nvim'),

    -- Mini plugins
    gh('echasnovski/mini.icons'),
    gh('echasnovski/mini.statusline'),

    -- Completion
    {
        src = gh('saghen/blink.cmp'),
        version = vim.version.range('1.*'),
    },
    -- Telescope and dependencies
    gh('nvim-lua/plenary.nvim'),
    gh('nvim-tree/nvim-web-devicons'),
    gh('nvim-telescope/telescope.nvim'),
    gh('nvim-telescope/telescope-fzf-native.nvim'),
    gh('nvim-telescope/telescope-ui-select.nvim'),

    -- Git
    gh('lewis6991/gitsigns.nvim'),
    gh('tpope/vim-fugitive'),

    -- LSP
    gh('folke/lazydev.nvim'),
    gh('neovim/nvim-lspconfig'),
    { src = gh('mason-org/mason.nvim'), name = 'mason.nvim' },

    -- Treesitter
    {
        src = gh('nvim-treesitter/nvim-treesitter'),
        -- version = 'master'
    },

    -- Copilot
    gh('github/copilot.vim'),
    { src = gh('CopilotC-Nvim/CopilotChat.nvim'), name = 'CopilotChat.nvim' },

    -- SonarLint
    { src = 'https://gitlab.com/schrieveslaach/sonarlint.nvim', name = 'sonarlint.nvim' },
})

-------------------------------------------------------------------------------
-- Plugin Configuration
-------------------------------------------------------------------------------

-- Colorscheme ----------------------------------------------------------------
vim.cmd.colorscheme('kanagawa')

-- Mini -----------------------------------------------------------------------
require('mini.icons').setup({})
require('mini.statusline').setup({
    use_icons = true,
})

-- Completion (blink.cmp) -----------------------------------------------------
require('blink.cmp').setup({
    keymap = { preset = 'default' },
    appearance = {
        nerd_font_variant = 'mono',
    },
    completion = {
        documentation = { auto_show = true },
    },
    sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
    fuzzy = { implementation = 'prefer_rust_with_warning' },
})

-- Telescope ------------------------------------------------------------------
require('telescope').setup({})
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader>sb', builtin.buffers, { desc = '[ ] Find existing buffers' })

vim.keymap.set('n', '<leader>s/', function()
    builtin.live_grep({
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
    })
end, { desc = '[S]earch [/] in Open Files' })

-- Git (gitsigns) -------------------------------------------------------------
require('gitsigns').setup({
    on_attach = function(bufnr)
        local gitsigns = require('gitsigns')

        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
            if vim.wo.diff then
                vim.cmd.normal({ ']c', bang = true })
            else
                gitsigns.nav_hunk('next')
            end
        end)

        map('n', '[c', function()
            if vim.wo.diff then
                vim.cmd.normal({ '[c', bang = true })
            else
                gitsigns.nav_hunk('prev')
            end
        end)

        -- Actions
        map('n', '<leader>hs', gitsigns.stage_hunk)
        map('n', '<leader>hr', gitsigns.reset_hunk)

        map('v', '<leader>hs', function()
            gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end)

        map('v', '<leader>hr', function()
            gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end)

        map('n', '<leader>hS', gitsigns.stage_buffer)
        map('n', '<leader>hR', gitsigns.reset_buffer)
        map('n', '<leader>hp', gitsigns.preview_hunk)
        map('n', '<leader>hi', gitsigns.preview_hunk_inline)

        map('n', '<leader>hb', function()
            gitsigns.blame_line({ full = true })
        end)

        map('n', '<leader>hd', gitsigns.diffthis)

        map('n', '<leader>hD', function()
            gitsigns.diffthis('~')
        end)

        map('n', '<leader>hQ', function() gitsigns.setqflist('all') end)
        map('n', '<leader>hq', gitsigns.setqflist)

        -- Toggles
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
        map('n', '<leader>tw', gitsigns.toggle_word_diff)

        -- Text object
        map({ 'o', 'x' }, 'ih', gitsigns.select_hunk)
    end,
})

-- LSP ------------------------------------------------------------------------

-- lazydev (Lua LSP for Neovim config)
require('lazydev').setup({
    library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
    },
})

-- Mason
require('mason').setup({})

-- LSP keymaps and attach behavior
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(event)
        local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[Code] [A]ction', { 'n', 'x' })
        map('<leader>gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('<leader>gi', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('<leader>gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        map('<leader>gt', vim.lsp.buf.type_definition, '[G]oto [T]ype Definition')
        map('<leader>O', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
        map('<leader>W', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')

        -- local client = vim.lsp.get_client_by_id(event.data.client_id)
        -- if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
        --     map('<leader>th', function()
        --         vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
        --     end, '[T]oggle Inlay [H]ints')
        -- end
    end,
})

-- LSP server configs
local servers = {
    eslint = {},
    ts_ls = {},
    lua_ls = {
        cmd = { 'lua-language-server' },
        filetypes = { 'lua' },
        root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
        settings = {
            Lua = {
                runtime = { version = 'LuaJIT' },
                workspace = { checkThirdParty = false },
                telemetry = { enable = false },
            },
        },
    },
    snyk_ls = {
        init_options = {
            organization = 'exchange-fx-and-active-cx',
            token = '738d0e3d-db51-4f0d-953d-1d630c477a81',
            trustedFolders = {
                '/home/user/projects',
            },
        },
    },
}

vim.lsp.config('lua_ls', servers.lua_ls)
vim.lsp.config('snyk_ls', servers.snyk_ls)

vim.lsp.enable(vim.tbl_keys(servers))

-- Treesitter -----------------------------------------------------------------
vim.api.nvim_create_autocmd('PackChanged', { callback = function(ev)
  local name, kind = ev.data.spec.name, ev.data.kind
  if name == 'nvim-treesitter' and kind == 'update' then
    if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
    vim.cmd('TSUpdate')
  end
end })
vim.api.nvim_create_autocmd('FileType', {
    callback = function()
        -- Enable treesitter highlighting and disable regex syntax
        pcall(vim.treesitter.start)
        -- Enable treesitter-based indentation
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})
require('nvim-treesitter').install{
    'lua', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash',
    'css', 'dockerfile', 'git_config', 'git_rebase', 'gitignore',
    'gitcommit', 'gitattributes', 'html', 'jsdoc', 'markdown',
    'markdown_inline',
}
-- require('nvim-treesitter').setup({
--     -- install_dir = vim.fn.stdpath('data') .. '/site',
--     ensure_installed = {
--         'lua', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash',
--         'css', 'dockerfile', 'git_config', 'git_rebase', 'gitignore',
--         'gitcommit', 'gitattributes', 'html', 'jsdoc', 'markdown',
--         'markdown_inline',
--     },
--     auto_install = false,
--     indent = { enable = true },
--     highlight = {
--         enable = true,
--         disable = function(lang, buf)
--             local max_filesize = 100 * 1024 -- 100 KB
--             local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
--             if ok and stats and stats.size > max_filesize then
--                 return true
--             end
--         end,
--         additional_vim_regex_highlighting = false,
--     },
--     textobjects = {
--         move = {
--             enable = true,
--             set_jumps = true,
--             goto_next_start = {
--                 [']m'] = '@function.outer',
--                 [']]'] = '@class.outer',
--             },
--             goto_next_end = {
--                 [']M'] = '@function.outer',
--                 [']['] = '@class.outer',
--             },
--             goto_previous_start = {
--                 ['[m'] = '@function.outer',
--                 ['[['] = '@class.outer',
--             },
--             goto_previous_end = {
--                 ['[M'] = '@function.outer',
--                 ['[]'] = '@class.outer',
--             },
--         },
--     },
-- })

-- Copilot / CopilotChat ------------------------------------------------------
require('CopilotChat').setup({
    model = 'claude-sonnet-4.6',
})
vim.g.copilot_no_tab_map = true
vim.keymap.set('i', '<S-Tab>', 'copilot#Accept("\\<S-Tab>")', { expr = true, replace_keycodes = false })

-- SonarLint ------------------------------------------------------------------
require('lspconfig')

require('sonarlint').setup({
    connected = {
        get_credentials = function(client_id, url)
            vim.notify('Getting SonarLint credentials for ' .. client_id .. ' at ' .. url)
            return vim.fn.getenv('SONAR_TOKEN')
        end,
    },
    server = {
        cmd = {
            'sonarlint-language-server',
            '-stdio',
            '-analyzers',
            vim.fn.expand('$MASON/share/sonarlint-analyzers/sonarhtml.jar'),
            vim.fn.expand('$MASON/share/sonarlint-analyzers/sonarjs.jar'),
            vim.fn.expand('$MASON/share/sonarlint-analyzers/sonartext.jar'),
        },
        settings = {
            sonarlint = {
                connectedMode = {
                    connections = {
                        sonarqube = {},
                        sonarcloud = {
                            {
                                organizationKey = 'transport-exchange-group',
                                disableNotifications = false,
                            },
                        },
                    },
                },
            },
        },
        before_init = function(params, config)
            local cwd = vim.fn.getcwd()
            if cwd.find(cwd, 'apps') then
                local path = cwd .. '/.sonarlint/connectedMode.json'
                local content = table.concat(vim.fn.readfile(path), '\n')
                local data = vim.json.decode(content)

                config.settings.sonarlint.connectedMode.project = {
                    projectKey = data.projectKey,
                }
            end
        end,
    },
    filetypes = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
        'html',
        'css',
    },
})
