return {
    'https://gitlab.com/schrieveslaach/sonarlint.nvim',
    enabled = true,

    config = function()
        require('lspconfig')

        require('sonarlint').setup({
            connected = {
                -- client_id is the ID of the Sonar LSP
                -- url is the url it wants to connect to
                get_credentials = function(client_id, url)
                    vim.notify("Getting SonarLint credentials for " .. client_id .. " at " .. url)
                    -- This must return a string (User token)
                    -- This is the default function. You can just set the environment variable.
                    return vim.fn.getenv("SONAR_TOKEN")
                end,
            },
            server = {
                cmd = {
                    'sonarlint-language-server',
                    -- Ensure that sonarlint-language-server uses stdio channel
                    '-stdio',
                    '-analyzers',
                    -- -- paths to the analyzers you need, using those for python and java in this example
                    vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarhtml.jar"),
                    vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarjs.jar"),
                    vim.fn.expand("$MASON/share/sonarlint-analyzers/sonartext.jar"),
                },
                settings = {
                    sonarlint = {
                        -- pathToNodeExecutable = vim.fn.exepath("node"),
                        connectedMode = {
                            connections = {
                                sonarqube = {
                                    -- {
                                --         -- connectionId = vim.fn.getcwd(),
                                -- --         -- this is the url that will go into get_credentials
                                        -- serverUrl = "https://<sq-domain.yourcompany.com>",
                                --         disableNotifications = false,
                                    -- },
                                },
                                sonarcloud = {
                                    {
                                        -- connectionId = "<server id to use in projects>",
                                        -- region = "EU", -- or EU
                                        organizationKey = "transport-exchange-group",
                                        disableNotifications = false,
                                        -- token = vim.fn.getenv("SONAR_TOKEN"),
                                    },
                                },
                            },
                        },
                    },
                },
                before_init = function(params, config)
                    local cwd = vim.fn.getcwd()
                    if cwd.find(cwd, 'apps') then
                        local path = cwd .. "/.sonarlint/connectedMode.json"
                        local content = table.concat(vim.fn.readfile(path), "\n")
                        local data = vim.json.decode(content)

                        config.settings.sonarlint.connectedMode.project = {
                            -- connectionId = "<server id from above>",
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
                "typescriptreact",
                "typescript.tsx",
                'html',
                'css',
            }
        })
    end
}
