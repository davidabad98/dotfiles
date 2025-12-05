-- lua/plugins/none-ls.lua
return {
	{
		"nvimtools/none-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					-- Lua
					null_ls.builtins.formatting.stylua,

					-- Python: Ruff does *all* formatting, including imports
					-- Prefer ruff_format (calls `ruff format`) over the older `ruff` fixer
					require("none-ls.formatting.ruff_format"),
					require("none-ls.diagnostics.ruff"), -- keep for linting if you like
					-- Drop isort to avoid double-import-sorting
					-- null_ls.builtins.formatting.isort,
				},

				on_attach = function(client, bufnr)
					if
						client.supports_method and client.supports_method("textDocument/formatting")
						or (client.server_capabilities and client.server_capabilities.documentFormattingProvider)
					then
						local grp = vim.api.nvim_create_augroup("NullLsFormat." .. bufnr, { clear = true })

						vim.api.nvim_create_autocmd("BufWritePre", {
							group = grp,
							buffer = bufnr,
							callback = function()
								vim.lsp.buf.format({
									bufnr = bufnr,
									async = false,
									filter = function(c)
										return c.name == "null-ls"
									end,
								})
							end,
						})
					end
				end,
			})

			-- optional keymap (manual format)
			vim.keymap.set("n", "<leader>gf", function()
				vim.lsp.buf.format({
					async = false,
					filter = function(c)
						return c.name == "null-ls"
					end,
				})
			end)
		end,
	},
	{
		"nvimtools/none-ls-extras.nvim",
		dependencies = { "nvimtools/none-ls.nvim" },
	},
}
