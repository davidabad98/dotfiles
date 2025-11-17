-- lua/plugins/comment.lua
return {
	"numToStr/Comment.nvim",
	event = "VeryLazy",
	config = function()
		require("Comment").setup()
	end,
}
