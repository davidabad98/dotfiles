-- lua/plugins/vim-dadbod.lua
-- Professional DB workflow: dadbod + UI + completion (nvim-cmp)
return {
	{
		"tpope/vim-dadbod",
		lazy = true,
		cmd = { "DB", "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
	},
	{
		"kristijanhusak/vim-dadbod-ui",
		dependencies = {
			"tpope/vim-dadbod",
			-- completion engine (nvim-cmp)
			"kristijanhusak/vim-dadbod-completion",
		},
		cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
		init = function()
			-- UI niceties
			vim.g.db_ui_use_nerd_fonts = 1
			vim.g.db_ui_win_position = "left"
			vim.g.db_ui_winwidth = 35
			-- where saved queries & saved connections are stored
			-- ~/.local/share/nvim/db_ui
			vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"

			-- (Optional) allow .env files to define multiple DBs via DB_UI_* variables
			-- requires tpope/vim-dotenv if you want auto-loading of .env
			-- vim.g.db_ui_dotenv_variable_prefix = "DB_UI_"
		end,
		config = function()
			-- nothing required here; DBUI reads globals set above
		end,
	},
	{
		-- Completion wiring for SQL buffers
		"kristijanhusak/vim-dadbod-completion",
		ft = { "sql", "mysql", "plsql" },
		init = function()
			-- If you use nvim-cmp, add dadbod source for SQL filetypes:
			local ok_cmp, cmp = pcall(require, "cmp")
			if ok_cmp then
				cmp.setup.filetype({ "sql", "mysql", "plsql" }, {
					sources = cmp.config.sources({
						{ name = "vim-dadbod-completion" },
					}, {
						{ name = "buffer" },
						{ name = "path" },
					}),
				})
			end
		end,
	},
}
