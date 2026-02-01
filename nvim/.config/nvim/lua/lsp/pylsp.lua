-- lua/lsp/pylsp.lua  
-- Configure pylsp ONLY for rope refactoring actions (extract method, etc.)
-- Basedpyright handles type checking, completions, and auto-imports.
-- Ruff (via none-ls) handles linting and formatting.

return {
	filetypes = { "python" },
	
	settings = {
		pylsp = {
			plugins = {
				-- Enable rope for refactoring actions only
				pylsp_rope = {
					enabled = true,
					rename = true,
				},
				
				-- Disable ALL other features (basedpyright handles these)
				jedi_completion = { enabled = false },
				jedi_hover = { enabled = false },
				jedi_references = { enabled = false },
				jedi_signature_help = { enabled = false },
				jedi_symbols = { enabled = false },
				rope_completion = { enabled = false },
				
				-- Disable linting (Ruff handles this via none-ls)
				mccabe = { enabled = false },
				pycodestyle = { enabled = false },
				pyflakes = { enabled = false },
				pylint = { enabled = false },
				ruff = { enabled = false }, -- We use ruff via none-ls instead
				
				-- Disable formatting (Ruff handles this via none-ls)
				autopep8 = { enabled = false },
				yapf = { enabled = false },
				black = { enabled = false },
			},
		},
	},
	
	on_attach = function(client, bufnr)
		-- Disable capabilities that basedpyright provides
		client.server_capabilities.hoverProvider = false
		client.server_capabilities.completionProvider = false
		client.server_capabilities.diagnosticProvider = false
		client.server_capabilities.referencesProvider = false
		client.server_capabilities.definitionProvider = false
		client.server_capabilities.signatureHelpProvider = false
		
		-- Keep ONLY code actions (for rope refactoring)
		-- client.server_capabilities.codeActionProvider remains enabled
	end,
}
