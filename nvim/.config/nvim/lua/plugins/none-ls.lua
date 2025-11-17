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

					-- Python via extras:
					null_ls.builtins.formatting.isort, -- sort imports first
					require("none-ls.diagnostics.ruff"), -- lint (ruff check)
					require("none-ls.formatting.ruff"), -- format (ruff fmt)
				},

				on_attach = function(client, bufnr)
					if client.server_capabilities and client.server_capabilities.documentFormattingProvider then
						local grp = vim.api.nvim_create_augroup("NullLsFormat." .. bufnr, { clear = true })
						vim.api.nvim_create_autocmd("BufWritePre", {
							group = grp,
							buffer = bufnr,
							callback = function()
								vim.lsp.buf.format({
									bufnr = bufnr,
									-- ensure we use null-ls for formatting
									filter = function(c)
										return c.name == "null-ls"
									end,
									async = false,
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
