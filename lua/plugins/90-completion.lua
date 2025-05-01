return {
    {
        "saghen/blink.cmp",

        dependencies = {
            "rafamadriz/friendly-snippets",
            "Kaiser-Yang/blink-cmp-avante",
        },

        version = "*",

        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
            -- 'super-tab' for mappings similar to vscode (tab to accept)
            -- 'enter' for enter to accept
            -- 'none' for no mappings
            --
            -- All presets have the following mappings:
            -- C-space: Open menu or open docs if already open
            -- C-n/C-p or Up/Down: Select next/previous item
            -- C-e: Hide menu
            -- C-k: Toggle signature help (if signature.enabled = true)
            --
            -- See :h blink-cmp-config-keymap for defining your own keymap
            keymap = {
                preset = "super-tab",
                ["<Up>"] = { "select_prev", "fallback" },
                ["<Down>"] = { "select_next", "fallback" },

                ["<S-space>"] = {
                    function(cmp)
                        cmp.show({ providers = { "snippets" } })
                    end,
                },
            },

            appearance = {
                -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = "mono",
            },

            -- (Default) Only show the documentation popup when manually triggered
            completion = { documentation = { auto_show = false } },

            -- Default list of enabled providers defined so that you can extend it
            -- elsewhere in your config, without redefining it, due to `opts_extend`
            sources = {
                default = { "avante", "lsp", "path", "snippets", "buffer" },
                providers = {
                    avante = {
                        module = "blink-cmp-avante",
                        name = "Avante",
                        opts = {
                            -- options for blink-cmp-avante
                        },
                    },
                },
            },

            -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
            -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
            -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
            --
            -- See the fuzzy documentation for more information
            fuzzy = { implementation = "prefer_rust_with_warning" },
        },
        opts_extend = { "sources.default" },
    },
    {
        "hrsh7th/nvim-cmp",
        enabled = false,
        version = nil,
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/vim-vsnip",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
        },
        config = function()
            local cmp = require("cmp")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        vim.fn["vsnip#anonymous"](args.body)
                    end,
                },
                sources = require("cmp").config.sources({
                    { name = "copilot" },
                    { name = "nvim_lsp" },
                    { name = "cmp_r" },
                    { name = "vsnip" },
                    { name = "path" },
                    { name = "buffer" },
                }),
                mapping = {
                    ["<up>"] = cmp.mapping.select_prev_item(),
                    ["<down>"] = cmp.mapping.select_next_item(),
                    ["<tab>"] = cmp.mapping.confirm({ select = true }),
                    ["<c-enbter>"] = cmp.mapping.confirm({ select = true }),
                    ["<enter>"] = cmp.mapping.confirm(),
                    ["<esc>"] = function()
                        cmp.abort()
                        vim.cmd("stopinsert")
                    end,
                },
            })

            vim.api.nvim_create_autocmd({ "CursorHoldI", "TextChangedI" }, {
                callback = cmp.complete,
            })
        end,
    },
}
