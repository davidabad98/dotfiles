-- lua/plugins/lsp-config.lua
return {
  -- mason
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end
  },

  -- mason-lspconfig: ensure servers are installed, then register configs via vim.lsp.config
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      -- list servers you want installed / enabled
      local servers = { "lua_ls", "pyright" }  -- add more as needed "omnisharp" 

      -- install servers via mason
      require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_installation = true,
      })

      -- common capabilities (adds cmp support if available)
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      if ok_cmp and cmp_nvim_lsp and cmp_nvim_lsp.default_capabilities then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
      end

      -- common on_attach for LSP keymaps (per-buffer)
      local on_attach = function(client, bufnr)
        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
        -- add whatever mappings you prefer
      end

      -- register & enable each server
      for _, name in ipairs(servers) do
        -- try to load a per-server config file: lua/lsp/<name>.lua
        local ok, server_opts = pcall(require, "lsp." .. name)
        if not ok then
          server_opts = {}
        end

        -- provide default on_attach/capabilities if not specified by the file
        server_opts.on_attach = server_opts.on_attach or on_attach
        server_opts.capabilities = server_opts.capabilities or capabilities

        -- register the server config with the new API
        vim.lsp.config(name, server_opts)

        -- enable the server (call pcall to avoid hard errors during changes)
        pcall(vim.lsp.enable, name)
      end
    end
  },

  -- keep nvim-lspconfig plugin installed, but we don't call the legacy setup()
  { "neovim/nvim-lspconfig" },
}

