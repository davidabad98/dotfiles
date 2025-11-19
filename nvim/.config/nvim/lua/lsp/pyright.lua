-- lua/lsp/pyright.lua
return {
	-- Optional: limit filetypes (pyright already defaults)
	filetypes = { "python" },

	-- Settings for pyright
	settings = {
		python = {
			analysis = {
				-- recommended defaults; tune to taste
				typeCheckingMode = "basic", -- off, basic, strict
				useLibraryCodeForTypes = true,
				diagnosticMode = "workspace", -- analyze entire project
				autoSearchPaths = true,
			},
		},
	},

	-- Pyright: language features + type checking.
	-- Ruff (via none-ls): linting + formatting.
}
