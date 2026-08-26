-- lua/plugins/treesitter.lua
-- nvim-treesitter `main` branch (rewrite) — Neovim 0.12+ / 0.13-dev required
-- See https://github.com/nvim-treesitter/nvim-treesitter (main) and :h nvim-treesitter
-- Migrated from legacy `nvim-treesitter.configs` (master) which is frozen / broken on 0.12+
return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false, -- main branch does not support lazy-loading (see README)
		branch = "main",
		build = ":TSUpdate",
		config = function()
			-- Optional: override install_dir (defaults to stdpath("data").."/site")
			require("nvim-treesitter").setup({
				install_dir = vim.fn.stdpath("data") .. "/site",
			})

			-- Parsers to ensure installed (async, no-op if already present).
			-- Keep in sync with languages you actually edit. Add/remove as needed.
			-- Previous master config had auto_install = true with commented ensure_installed;
			-- main branch requires explicit install.
			-- Guard: nvim-treesitter `main` needs `tree-sitter` CLI 0.26.1+ + C compiler.
			-- Without it, install fails with ENOENT. Check before calling install to avoid spam.
			local ensure_installed = {
				"lua",
				"vim",
				"vimdoc",
				"query",
				"javascript",
				"typescript",
				"tsx",
				"python",
				"c_sharp",
				"razor",
				"html",
				"css",
				"sql",
				"json",
				"markdown",
				"markdown_inline",
				"yaml",
				"toml",
				"bash",
			}
			if vim.fn.executable("tree-sitter") == 1 then
				require("nvim-treesitter").install(ensure_installed)
			else
				-- Defer warning until VeryLazy so it doesn't spam early startup
				vim.api.nvim_create_autocmd("User", {
					pattern = "VeryLazy",
					once = true,
					callback = function()
						vim.notify(
							"[nvim-treesitter] `tree-sitter` CLI not found (need 0.26.1+). Parsers will not auto-install.\nInstall with: npm i -g tree-sitter-cli  (0.26.13) or: cargo install tree-sitter-cli\nThen run :TSUpdate",
							vim.log.levels.WARN
						)
					end,
				})
			end

			-- Enable treesitter highlighting / indentation per buffer when a parser exists.
			-- New API: features are not auto-enabled; use FileType autocmd (see :h nvim-treesitter).
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("nvim-treesitter-enable", { clear = true }),
				callback = function(args)
					-- Try to start treesitter for this buffer; silently no-op if parser missing
					local ok = pcall(vim.treesitter.start, args.buf)
					if ok then
						-- Indentation provided by nvim-treesitter (opt-in)
						vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
						-- Optional: folds via treesitter (uncomment if you want)
						-- vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
						-- vim.wo.foldmethod = "expr"
					end
				end,
			})
		end,
	},
	{
		-- Setup Sticky Scroll
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("treesitter-context").setup({
				enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
				multiwindow = false, -- Enable multiwindow support.
				max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
				min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
				line_numbers = true,
				multiline_threshold = 20, -- Maximum number of lines to show for a single context
				trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
				mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
				-- Separator between context and content. Should be a single character string, like '-'.
				-- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
				separator = nil,
				zindex = 20, -- The Z-index of the context window
				on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
			})
		end,
	},
}
