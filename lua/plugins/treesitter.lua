return {
    "nvim-treesitter/nvim-treesitter",
    branch = 'master',
    lazy = false,
    build = ":TSUpdate",
    opts = {
        ensure_installed = { 'lua', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash', 'css', 'dockerfile', 'git_config', 'git_rebase', 'gitignore', 'gitcommit', 'gitattributes', 'html', 'jsdoc', 'markdown', 'markdown_inline' },
        auto_install = false,
        indent = { enable = true },
        highlight = {
            enable = true,
            -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
            disable = function(lang, buf)
                local max_filesize = 100 * 1024 -- 100 KB
                local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                if ok and stats and stats.size > max_filesize then
                    return true
                end
            end,

            -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
            -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
            -- Using this option may slow down your editor, and you may see some duplicate highlights.
            -- Instead of true it can also be a list of languages
            additional_vim_regex_highlighting = false,
        },
        textobjects = {
            -- select = {
            --     enable = true,
            --     lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            --     keymaps = {
            --         -- You can use the capture groups defined in textobjects.scm
            --         ['aa'] = '@parameter.outer',
            --         ['ia'] = '@parameter.inner',
            --         ['af'] = '@function.outer',
            --         ['if'] = '@function.inner',
            --         ['ac'] = '@class.outer',
            --         ['ic'] = '@class.inner',
            --     },
            -- },
            move = {
                enable = true,
                set_jumps = true, -- whether to set jumps in the jumplist
                goto_next_start = {
                    [']m'] = '@function.outer',
                    [']]'] = '@class.outer',
                },
                goto_next_end = {
                    [']M'] = '@function.outer',
                    [']['] = '@class.outer',
                },
                goto_previous_start = {
                    ['[m'] = '@function.outer',
                    ['[['] = '@class.outer',
                },
                goto_previous_end = {
                    ['[M'] = '@function.outer',
                    ['[]'] = '@class.outer',
                },
            },
        },
    },
}
