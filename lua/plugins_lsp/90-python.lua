if should_enable("python") then
    return {
        {
            "mfussenegger/nvim-dap-python",
            lazy = true,
            ft = "python",
            config = function()
                require("dap-python").setup("/usr/bin/python")
            end,
        },
        {
            "linux-cultist/venv-selector.nvim",
            branch = "regexp",
            dependencies = {
                "neovim/nvim-lspconfig",
                "nvim-telescope/telescope.nvim",
                "mfussenegger/nvim-dap-python",
            },
            opts = {
                search = {
                    project_venvs = {
                        command = "fd -I 'python$' ~/projects/venvs --full-path",
                    },
                    hatch_venvs = {
                        command = "fd -I 'python$' ~/.config/hatch/env --full-path",
                    },
                },
            },
            -- event = 'VeryLazy', -- Optional: needed only if you want to type `:VenvSelect` without a keymapping
            keys = {
                -- Keymap to open VenvSelector to pick a venv.
                { "<leader>vs", "<cmd>VenvSelect<enter>" },
                -- Keymap to retrieve the venv from a cache (the one previously used for the same project directory).
                { "<leader>vc", "<cmd>VenvSelectCached<enter>" },
            },
        },
    }
else
    return {}
end
