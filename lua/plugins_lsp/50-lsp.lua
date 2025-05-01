return {
    {
        "williamboman/mason.nvim",
        opts = {},
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = {
            ensure_installed = {
                -- shell
                "beautysh",
                "shellcheck",

                -- markdown
                "markdown-oxide",

                -- html/css
                "prettierd",
                "stylelint",

                -- lua
                "selene",
                "stylua",

                -- XML
                "xmlformatter",

                -- SQL
                "sqls",
                "sql-formatter",
            },
            auto_update = true,
            run_on_start = true,
        },
        config = function(_, opts)
            local deps = {
                ansible = { "ansible-language-server", "ansible-lint" },
                python = { "basedpyright", "ruff" },
                gcc = { "clangd", "codelldb", "cpptools" },
                elixir = { "elixir-ls" },
                erlang = { "erlang-ls" },
                go = { "gopls" },
                latex = { "texlab" },
                node = { "typescript-language-server" },
                perl = { "perlnavigator" },
            }
            local ensure_installed = opts.ensure_installed
            for group, dependencies in pairs(deps) do
                if should_enable(group) then
                    for _, dep in ipairs(dependencies) do
                        if not vim.tbl_contains(ensure_installed, dep) then
                            table.insert(ensure_installed, dep)
                        end
                    end
                end
            end
            require("mason-tool-installer").setup(opts)
        end,
    },
    {
        "nanotee/sqls.nvim",
    },
    {
        "SmiteshP/nvim-navic",
        requires = "neovim/nvim-lspconfig",
    },
    {
        "neovim/nvim-lspconfig",
        branch = "master",
        version = nil,
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup()

            local lspconfig = require("lspconfig")

            -- TODO incorporate current code location in statusline
            lspconfig.basedpyright.setup({
                settings = {
                    basedpyright = {
                        typeCheckingMode = "standard",
                    },
                },
            })

            lspconfig.perlnavigator.setup({
                settings = {
                    perlnavigator = {
                        includePaths = { "~/perl5/lib/perl5" },
                    },
                },
            })

            lspconfig.sqls.setup({
                on_attach = function(client, bufnr)
                    client.server_capabilities.documentFormattingProvider = false
                    require("sqls").on_attach(client, bufnr)
                    require("nvim-navic").attach(client, bufnr)
                end,
            })

            local servers = { "erlangls", "elixirls", "ansiblels", "gopls", "texlab", "clangd", "ts_ls" }
            for _, lsp in ipairs(servers) do
                lspconfig[lsp].setup({
                    on_attach = function(client, bufnr)
                        require("nvim-navic").attach(client, bufnr)
                    end,
                })
            end

            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(ev)
                    print(
                        "LS attached buf=" .. ev.buf .. " client=" .. vim.lsp.get_client_by_id(ev.data.client_id).name
                    )

                    vim.keymap.set(
                        "n",
                        "gr",
                        require("telescope.builtin").lsp_references,
                        { buffer = true, desc = "Jump to reference" }
                    )
                    vim.keymap.set("n", "bgd", function()
                        require("telescope.builtin").lsp_definitions()
                    end, { buffer = true, desc = "Jump to definition" })
                    vim.keymap.set("n", "sgd", function()
                        require("telescope.builtin").lsp_definitions({ jump_type = "vsplit" })
                    end, { buffer = true, desc = "Jump to definition" })
                    vim.keymap.set("n", "gd", function()
                        require("telescope.builtin").lsp_definitions({ jump_type = "tab" })
                    end, { buffer = true, desc = "Jump to definition" })
                    vim.keymap.set(
                        "n",
                        "gi",
                        require("telescope.builtin").lsp_implementations,
                        { buffer = true, desc = "Jump to implementation" }
                    )

                    vim.keymap.set(
                        "n",
                        "<leader>d",
                        "<cmd>Lspsaga hover_doc<enter>",
                        { desc = "LSP hover doc", buffer = true }
                    )
                    vim.keymap.set(
                        "n",
                        "gD",
                        "<cmd>Lspsaga peek_definition<enter>",
                        { desc = "LSP peek definition", buffer = true }
                    )
                    vim.keymap.set(
                        "n",
                        "gT",
                        "<cmd>Lspsaga peek_type_definition<enter>",
                        { desc = "LSP peek type definition", buffer = true }
                    )
                    vim.keymap.set(
                        "n",
                        "<leader>v",
                        "<cmd>Lspsaga outline<enter>",
                        { desc = "LSP outline", buffer = true }
                    )
                    vim.keymap.set(
                        "n",
                        "<leader>Q",
                        "<cmd>Lspsaga show_workspace_diagnostics<enter>",
                        { desc = "LSP diagnostics", buffer = true }
                    )

                    vim.keymap.set("n", "<leader>n", function()
                        return ":IncRename " .. vim.fn.expand("<cword>")
                    end, { buffer = true, expr = true, desc = "LSP rename symbol" })

                    vim.keymap.set("n", "<leader>s", function()
                        vim.lsp.buf.format({ async = true })
                    end, { buffer = true, desc = "Format buffer" })
                end,
            })
        end,
    },
    {
        "nvimtools/none-ls.nvim",
        dependencies = {
            "gbprod/none-ls-shellcheck.nvim",
        },
        config = function()
            local null_ls = require("null-ls")

            local opts = {
                sources = {
                    null_ls.builtins.formatting.stylua,
                    null_ls.builtins.formatting.prettierd,
                    null_ls.builtins.formatting.sql_formatter,

                    null_ls.builtins.diagnostics.ansiblelint,
                    null_ls.builtins.diagnostics.selene,

                    require("none-ls-shellcheck.diagnostics"),
                    require("none-ls-shellcheck.code_actions"),
                },
            }

            null_ls.setup(opts)
        end,
    },
    {
        "aznhe21/actions-preview.nvim",
        config = function()
            vim.keymap.set(
                { "v", "n" },
                "<leader>a",
                require("actions-preview").code_actions,
                { desc = "LSP code actions" }
            )
        end,
    },
    {
        "smjonas/inc-rename.nvim",
        opts = {},
    },
    {
        "lewis6991/hover.nvim",
        -- enabled = false,
        config = function()
            require("hover").setup({
                init = function()
                    -- Require providers
                    require("hover.providers.lsp")
                    -- require('hover.providers.gh')
                    -- require('hover.providers.gh_user')
                    -- require('hover.providers.jira')
                    -- require('hover.providers.dap')
                    -- require('hover.providers.fold_preview')
                    -- require('hover.providers.diagnostic')
                    -- require('hover.providers.man')
                    -- require('hover.providers.dictionary')
                end,
                preview_opts = {
                    border = "single",
                },
                -- Whether the contents of a currently open hover window should be moved
                -- to a :h preview-window when pressing the hover keymap.
                preview_window = false,
                title = true,
                mouse_providers = {
                    "LSP",
                },
                mouse_delay = 1000,
            })

            -- Setup keymaps
            vim.keymap.set("n", "K", require("hover").hover, { desc = "hover.nvim" })
            vim.keymap.set("n", "gK", require("hover").hover_select, { desc = "hover.nvim (select)" })
            vim.keymap.set("n", "<C-p>", function()
                require("hover").hover_switch("previous")
            end, { desc = "hover.nvim (previous source)" })
            vim.keymap.set("n", "<C-n>", function()
                require("hover").hover_switch("next")
            end, { desc = "hover.nvim (next source)" })

            -- Mouse support
            vim.keymap.set("n", "<MouseMove>", require("hover").hover_mouse, { desc = "hover.nvim (mouse)" })
            vim.o.mousemoveevent = true
        end,
    },
    {
        "nvimdev/lspsaga.nvim",
        -- enabled = false,
        version = nil,
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            outline = {
                keys = {
                    toggle_or_jump = "<enter>",
                },
            },
            lightbulb = {
                enable = false,
            },
        },
    },
}
