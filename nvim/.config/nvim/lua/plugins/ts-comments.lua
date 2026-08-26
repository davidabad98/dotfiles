-- lua/plugins/ts-comments.lua
-- Replaces archived numToStr/Comment.nvim (see https://github.com/numToStr/Comment.nvim/issues/517)
-- Neovim 0.10+ has built-in `gc`/`gcc` via `commentstring`; this plugin adds
-- treesitter-aware commentstring calculation for embedded languages (html/vue/tsx/markdown etc.)
return {
	"folke/ts-comments.nvim",
	event = "VeryLazy",
	enabled = vim.fn.has("nvim-0.10.0") == 1,
	opts = {},
}
