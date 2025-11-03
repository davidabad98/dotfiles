-- lua/lsp/lua_ls.lua
return {
  -- optional: add custom on_attach or capabilities here; otherwise the global ones will be used
  -- on_attach = function(client, bufnr) ... end,

  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },   -- recognise `vim` global
      },
      workspace = {
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },

  -- optional: limit filetypes if you need
  filetypes = { "lua" },
}

