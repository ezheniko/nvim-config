return {
    {
        -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
        -- used for completion, annotations and signatures of Neovim apis
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
            library = {
                -- Load luvit types when the `vim.uv` word is found
                { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
            },
        },
    },
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            { 'mason-org/mason.nvim', opts = {} },
            'saghen/blink.cmp',
        },
        config = function()
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
                    -- map('<leader>gt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

                    -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
                    ---@param client vim.lsp.Client
                    ---@param method vim.lsp.protocol.Method
                    ---@param bufnr? integer some lsp support methods only in specific files
                    ---@return boolean
                    local function client_supports_method(client, method, bufnr)
                        if vim.fn.has 'nvim-0.11' == 1 then
                            return client:supports_method(method, bufnr)
                        else
                            return client.supports_method(method, { bufnr = bufnr })
                        end
                    end

                    -- The following code creates a keymap to toggle inlay hints in your
                    -- code, if the language server you are using supports them
                    --
                    -- This may be unwanted, since they displace some of your code
                    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
                        map('<leader>th', function()
                            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                        end, '[T]oggle Inlay [H]ints')
                    end
                end,
            })

            local servers = {
                eslint = {},
                ts_ls = {},
                lua_ls = {
                    settings = {
                        Lua = {
                            workspace = { checkThirdParty = false },
                            telemetry = { enable = false },
                        },
                    },
                },
                snyk_ls = {
                    -- cmd = {
                    --     '/usr/local/bin/snyk',
                    --     'language-server',
                    --     '-f',
                    --     vim.fn.stdpath('state') .. '/snyk-ls.log'
                    -- },
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
        end
    },
}
