-- =======================================================
-- Neovim Configuration for React.js & Next.js Development
-- =======================================================
-- 
-- "For I know the plans I have for you," declares the Lord, "plans to prosper you and not to harm you, plans to give you hope and a future." - Jeremiah 29:11
--
-- Bootstrap Lazy.nvim Plugin Manager (needed before loading plugins)
-- ===================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins from general config
-- ==================================
-- Load the general config early to access the global plugins table
local home_dir = vim.fn.expand("~")
local general_config_path = home_dir .. "/.config/nvim-general/plugins.lua"
local general_plugins = {}
local ok, err = pcall(function()
    dofile(general_config_path)
    general_plugins = plugins or {}
end)
if not ok then
    vim.notify("Could not load general config: " .. tostring(err),
               vim.log.levels.ERROR)
end

-- Plugin Configuration
-- =====================
require("lazy").setup({
    -- Plugins from general config (loaded without importing entire file)
    general_plugins, -- NPM Script Runner
    {
        "kassio/neoterm",
        keys = {
            {
                "<leader>db",
                function()
                    -- Read package.json and get scripts
                    local cwd = vim.fn.getcwd()
                    local package_json_path = cwd .. "/package.json"
                    local file = io.open(package_json_path, "r")
                    if not file then
                        vim.notify("No package.json found in current directory",
                                   vim.log.levels.WARN)
                        return
                    end

                    local content = file:read("*a")
                    file:close()

                    local ok, package_json = pcall(vim.json.decode, content)
                    if not ok or not package_json then
                        vim.notify("Failed to parse package.json",
                                   vim.log.levels.ERROR)
                        return
                    end

                    local scripts = package_json.scripts
                    if not scripts or type(scripts) ~= "table" or
                        vim.tbl_isempty(scripts) then
                        vim.notify("No scripts found in package.json",
                                   vim.log.levels.WARN)
                        return
                    end

                    -- Build list of script names
                    local script_names = {}
                    for name, _ in pairs(scripts) do
                        table.insert(script_names, name)
                    end
                    table.sort(script_names)

                    -- Show picker
                    vim.ui.select(script_names,
                                  {prompt = "Select npm script to run:"},
                                  function(choice)
                        if choice then
                            -- Set NODE_OPTIONS to fix localStorage issues with HtmlWebpackPlugin
                            local localStorage_file =
                                vim.fn.tempname() .. "-localstorage.json"
                            local cmd = string.format(
                                            'NODE_OPTIONS="--localstorage-file=%s" npm run %s',
                                            localStorage_file, choice)
                            -- Run the script in neoterm
                            vim.cmd("T " .. cmd)
                        end
                    end)
                end,
                desc = "Run npm script from package.json"
            }
        },
        config = function()
            -- Neoterm is already configured globally, nothing needed here
        end
    }, -- LSP Configuration for TypeScript/JavaScript
    {
        "neovim/nvim-lspconfig",
        config = function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            local cmp_nvim_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
            if cmp_nvim_lsp_ok then
                capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
            end

            -- TypeScript/JavaScript LSP (ts_ls replaces deprecated tsserver)
            vim.lsp.config("ts_ls", {
                capabilities = capabilities,
                settings = {
                    typescript = {
                        inlayHints = {
                            includeInlayParameterNameHints = "all",
                            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                            includeInlayFunctionParameterTypeHints = true,
                            includeInlayVariableTypeHints = true,
                            includeInlayPropertyDeclarationTypeHints = true,
                            includeInlayFunctionLikeReturnTypeHints = true,
                            includeInlayEnumMemberValueHints = true
                        }
                    },
                    javascript = {
                        inlayHints = {
                            includeInlayParameterNameHints = "all",
                            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                            includeInlayFunctionParameterTypeHints = true,
                            includeInlayVariableTypeHints = true,
                            includeInlayPropertyDeclarationTypeHints = true,
                            includeInlayFunctionLikeReturnTypeHints = true,
                            includeInlayEnumMemberValueHints = true
                        }
                    }
                }
            })
            vim.lsp.enable("ts_ls")

            -- Tailwind CSS LSP
            vim.lsp.config("tailwindcss", {capabilities = capabilities})
            vim.lsp.enable("tailwindcss")

            -- HTML LSP
            vim.lsp.config("html", {capabilities = capabilities})
            vim.lsp.enable("html")

            -- CSS LSP
            vim.lsp.config("cssls", {capabilities = capabilities})
            vim.lsp.enable("cssls")

            -- ESLint LSP
            vim.lsp.config("eslint", {
                capabilities = capabilities,
                on_attach = function(client, bufnr)
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        buffer = bufnr,
                        command = "EslintFixAll"
                    })
                end
            })
            vim.lsp.enable("eslint")

            -- React/Next.js keymaps
            local map = vim.keymap.set

            -- Run Next.js dev server
            map("n", "<leader>nr", function()
                vim.cmd("T npm run dev")
            end, {desc = "Next.js: Run Dev Server"})

            -- Run React dev server (CRA or Vite)
            map("n", "<leader>rs", function() vim.cmd("T npm start") end,
                {desc = "React: Start Dev Server"})

            -- Build production
            map("n", "<leader>nb", function()
                vim.cmd("T npm run build")
            end, {desc = "Build Production"})

            -- Run tests
            map("n", "<leader>nt", function() vim.cmd("T npm test") end,
                {desc = "Run Tests"})

            -- Stop terminal process
            map("n", "<leader>nq", function() vim.cmd("Tkill") end,
                {desc = "Kill Terminal Process"})
        end
    }, -- Tree-sitter (Syntax Highlighting)
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "javascript", "typescript", "tsx", "html", "css", "json",
                    "lua", "vim", "vimdoc", "markdown", "markdown_inline"
                },
                highlight = {enable = true},
                indent = {enable = true},
                autotag = {enable = true}
            })
        end
    }, -- Auto close/rename HTML tags
    {
        "windwp/nvim-ts-autotag",
        dependencies = {"nvim-treesitter/nvim-treesitter"},
        config = function() require("nvim-ts-autotag").setup() end
    }, -- Auto pairs for brackets
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({
                check_ts = true,
                ts_config = {
                    lua = {"string"},
                    javascript = {"template_string"},
                    typescript = {"template_string"}
                }
            })
            -- Integrate with nvim-cmp
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            local cmp = require("cmp")
            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end
    }, -- Color highlighter for CSS/Tailwind
    {
        "norcalli/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup({
                "css", "scss", "javascript", "javascriptreact", "typescript",
                "typescriptreact", "html"
            }, {
                RGB = true,
                RRGGBB = true,
                names = true,
                RRGGBBAA = true,
                rgb_fn = true,
                hsl_fn = true,
                css = true,
                css_fn = true
            })
        end
    }, -- Emmet for HTML/JSX
    {
        "mattn/emmet-vim",
        ft = {"html", "css", "javascriptreact", "typescriptreact"},
        config = function()
            vim.g.user_emmet_leader_key = "<C-z>"
            vim.g.user_emmet_settings = {
                javascript = {extends = "jsx"},
                typescript = {extends = "tsx"}
            }
        end
    }, -- Completion Engine
    {
        "williamboman/mason.nvim",
        config = function() require("mason").setup() end
    }, {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {"williamboman/mason.nvim"},
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "ts_ls", "eslint", "tailwindcss", "html", "cssls"
                },
                automatic_installation = true
            })
        end
    }, -- Formatting
    {
        "stevearc/conform.nvim",
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    javascript = {"prettier"},
                    javascriptreact = {"prettier"},
                    typescript = {"prettier"},
                    typescriptreact = {"prettier"},
                    json = {"prettier"},
                    css = {"prettier"},
                    scss = {"prettier"},
                    html = {"prettier"}
                },
                formatters = {
                    prettier = {
                        prepend_args = {"--single-quote", "--jsx-single-quote"}
                    }
                },
                format_on_save = {timeout_ms = 500, lsp_fallback = true}
            })
        end
    }, -- Linting
    {
        "mfussenegger/nvim-lint",
        config = function()
            local lint = require("lint")
            lint.linters_by_ft = {
                javascript = {"eslint"},
                javascriptreact = {"eslint"},
                typescript = {"eslint"},
                typescriptreact = {"eslint"}
            }
            -- Auto-run linters on save and when opening files
            vim.api.nvim_create_autocmd({"BufWritePost", "BufEnter"}, {
                callback = function() lint.try_lint() end
            })
        end
    }, -- LSP Saga (Enhanced LSP UI)
    {
        "nvimdev/lspsaga.nvim",
        event = "LspAttach",
        config = function()
            require("lspsaga").setup({
                symbol_in_winbar = {enable = false},
                ui = {border = "rounded", code_action = "💡"}
            })
        end,
        dependencies = {
            {"nvim-tree/nvim-web-devicons"}, {"nvim-treesitter/nvim-treesitter"}
        }
    }
})

-- Neoterm Configuration
-- =====================
vim.g.neoterm_size = tostring(math.floor(0.2 * vim.o.lines))
vim.g.neoterm_default_mod = 'botright horizontal'
vim.g.neoterm_autoinsert = 1

-- Diagnostics Configuration
-- ==========================
vim.diagnostic.config({
    virtual_text = {
        severity = {min = vim.diagnostic.severity.WARN},
        source = "always",
        prefix = "●",
        spacing = 4
    },
    signs = {
        {name = "DiagnosticSignError", text = "✗"},
        {name = "DiagnosticSignWarn", text = "⚠"},
        {name = "DiagnosticSignHint", text = "💡"},
        {name = "DiagnosticSignInfo", text = "ℹ"}
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {border = "rounded", source = "always", header = "", prefix = ""}
})

-- Comment String Configuration
-- =============================
vim.api.nvim_create_autocmd("FileType", {
    pattern = {
        "javascript", "typescript", "javascriptreact", "typescriptreact", "lua"
    },
    callback = function()
        if vim.bo.filetype == "javascript" or vim.bo.filetype == "typescript" or
            vim.bo.filetype == "javascriptreact" or vim.bo.filetype ==
            "typescriptreact" then
            vim.bo.commentstring = "// %s"
        elseif vim.bo.filetype == "lua" then
            vim.bo.commentstring = "-- %s"
        end
    end
})

-- Format on save (Prettier + ESLint)
-- =====================================
-- Note: conform.nvim handles format_on_save automatically, but we keep this
-- as a fallback and for manual formatting with <leader>lf
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = {
        "*.js", "*.jsx", "*.ts", "*.tsx", "*.json", "*.css", "*.scss", "*.html"
    },
    callback = function()
        local conform = require("conform")
        conform.format({async = false, lsp_fallback = true})
    end
})

-- Import general Neovim configuration
-- ====================================
local home_dir = vim.fn.expand("~")
dofile(home_dir .. "/.config/nvim-general/config.lua")
