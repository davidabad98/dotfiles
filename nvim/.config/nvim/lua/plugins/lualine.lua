-- lua/plugins/lualine.lua
local function lsp_indicator()
	local buf = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients({ bufnr = buf })

	if not clients or vim.tbl_isempty(clients) then
		return "" -- nothing when no LSP attached
	end

	-- pick any icon you like; this is a common one:
	return "  LSP"
end

return {
	"nvim-lualine/lualine.nvim",
	config = function()
		require("lualine").setup({
			options = {
				theme = "catppuccin",
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff" },
				lualine_c = { "filename" },
				lualine_x = {
					"encoding",
					"fileformat",
					"filetype",
					lsp_indicator, -- icon + "LSP" when active
				},
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		})
	end,
}
