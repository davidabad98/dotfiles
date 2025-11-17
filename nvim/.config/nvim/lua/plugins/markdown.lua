-- lua/plugins/markdown.lua
return {
	"MeanderingProgrammer/render-markdown.nvim",
	ft = { "markdown", "markdown.mdx" }, -- load only for markdown-like files
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	---@type render.md.UserConfig
	opts = {
		-- defaults you can tweak later
		-- enabled = true,
		-- preset = "none", -- "none" | "lazy" | "obsidian"
		-- file_types = { "markdown" },
	},
}
