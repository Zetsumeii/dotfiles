vim.lsp.config('rust_analyzer', {
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
})

vim.lsp.config('clangd', {})

vim.lsp.config('lua_ls', {})

vim.lsp.config('bashls', {})

vim.lsp.config('gitlab_ci_ls', {})

vim.lsp.config('dockerls', {})

vim.lsp.config('ts_ls', {})

vim.lsp.config('svelte', {})

vim.lsp.config('docker_compose_language_service', {})

vim.lsp.config('pyright', {})

vim.lsp.config('arduino_language_server', {
  cmd = {
    "arduino-language-server",
    "-cli-config", "/home/zetsumei/.arduino15/arduino-cli.yaml",
    "-fqbn", "esp32:esp32:esp32",
    "-cli", "arduino-cli",
    "-clangd", "clangd"
  }
})

vim.lsp.config('yamlls', {
  settings = {
    redhat = {
      telemetry = {
        enabled = false
      }
    },
    yaml = {
      format = {
        enable = true
      }
    }
  }
})

vim.lsp.config('tailwindcss', {
  settings = {
    tailwindCSS = {
      experimental = {
        classRegex = {
          "class:\\s*[\"'`]([^\"'`]*)[\"'`]",
        },
      },
    },
  },
})

vim.lsp.config('html', {})
vim.lsp.config('cssls', {})
vim.lsp.config('sqlls', {
    cmd = {"/usr/bin/sql-language-server", "up", "--method", "stdio"};
})

vim.lsp.enable({
  'rust_analyzer',
  'clangd',
  'lua_ls',
  'bashls',
  'gitlab_ci_ls',
  'dockerls',
  'ts_ls',
  'svelte',
  'tailwindcss',
  'html',
  'cssls',
  'docker_compose_language_service',
  'pyright',
  'arduino_language_server',
  'yamlls',
  'sqlls'
})
