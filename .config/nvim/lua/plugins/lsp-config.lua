local lspconfig = require('lspconfig')
lspconfig.rust_analyzer.setup {
  -- Server-specific settings. See `:help lspconfig-setup`
    settings = {
        ["rust-analyzer"] = {
            imports = {
                granularity = {
                    group = "module",
                },
                prefix = "self",
            },
            cargo = {
                buildScripts = {
                    enable = true,
                },
            },
            procMacro = {
                enable = true
            },
        }
    }
}
lspconfig.clangd.setup{}
lspconfig.lua_ls.setup{}
lspconfig.bashls.setup{}
lspconfig.gitlab_ci_ls.setup{}
lspconfig.dockerls.setup{}
lspconfig.ts_ls.setup{}
lspconfig.svelte.setup{}
lspconfig.docker_compose_language_service.setup{}
lspconfig.pyright.setup{}
