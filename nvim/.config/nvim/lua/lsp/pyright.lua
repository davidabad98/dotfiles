-- lua/lsp/pyright.lua
return {
  -- Optional: limit filetypes (pyright already defaults)
  filetypes = { "python" },

  -- Settings for pyright
  settings = {
    python = {
      analysis = {
        -- recommended defaults; tune to taste
        typeCheckingMode = "basic",       -- off, basic, strict
        useLibraryCodeForTypes = true,
        autoSearchPaths = true,
      },
    },
  },

  -- You can override on_attach/capabilities per-server; otherwise global ones are used.
  -- on_attach = function(client, bufnr) ... end,
}

