-- ========== Basic Settings ==========
vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true -- Relative numbers for quick jumps
vim.opt.tabstop = 2 -- Tab = 4 spaces
vim.opt.shiftwidth = 2 -- Indentation = 2 spaces
vim.opt.expandtab = true -- Convert tabs to spaces
vim.opt.smartindent = true -- Auto-indent new lines

vim.opt.wrap = false -- Don’t wrap long lines
vim.opt.cursorline = true -- Highlight current line
vim.opt.scrolloff = 8 -- Keep cursor away from edges
vim.opt.signcolumn = "yes" -- Always show sign column

-- Always save files with Unix line endings (global)
vim.o.fileformat = "unix"
vim.o.fileformats = "unix,dos"

-- ========== Search ==========
vim.opt.ignorecase = true -- Case-insensitive search...
vim.opt.smartcase = true -- ...unless capital letters in query
vim.opt.hlsearch = true -- Highlight search results
vim.opt.incsearch = true -- Show matches while typing
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>") -- Clear search when pressing Esc

-- ========== Clipboard ==========
vim.opt.clipboard = "unnamedplus" -- Use system clipboard

-- ========== UI ==========
vim.opt.termguicolors = true -- Enable 24-bit colors
vim.opt.splitbelow = true -- Split below
vim.opt.splitright = true -- Split right
vim.opt.colorcolumn = "88" -- Enable vertical ruler line

-- ========== Keymaps ==========

-- ========== Save & quit ==========

vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", {
	desc = "Save current buffer",
})

vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", {
	desc = "Quit window",
})

vim.keymap.set("n", "<leader>x", "<cmd>x<CR>", {
	desc = "Save and quit",
})

-- ========== Navigation ==========

-- Switch between buffers
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<CR>", {
	desc = "Previous buffer",
})
vim.keymap.set("n", "<S-l>", "<cmd>bnext<CR>", {
	desc = "Next buffer",
})

-- Splits & tabs
vim.keymap.set("n", "<leader>v", "<cmd>vsplit<CR>", {
	desc = "Vertical split",
})
vim.keymap.set("n", "<leader>s", "<cmd>split<CR>", {
	desc = "Horizontal split",
})
vim.keymap.set("n", "<leader>n", "<cmd>vnew<CR>", {
	desc = "New vertical empty buffer",
})
-- vim.keymap.set("n", "<leader>t", "<cmd>tabnew<CR>", {
-- 	desc = "New tab",
-- })

-- Window navigation with leader
-- vim.keymap.set("n", "<leader>h", "<C-w>h", {
-- 	desc = "Focus left window",
-- })
-- vim.keymap.set("n", "<leader>j", "<C-w>j", {
-- 	desc = "Focus lower window",
-- })
-- vim.keymap.set("n", "<leader>k", "<C-w>k", {
-- 	desc = "Focus upper window",
-- })
-- vim.keymap.set("n", "<leader>l", "<C-w>l", {
-- 	desc = "Focus right window",
-- })

-- ========== Quickfix ==========
vim.keymap.set("n", "<C-j>", "<cmd>cnext<CR>zz", { desc = "Quickfix Next (centered)" })
vim.keymap.set("n", "<C-k>", "<cmd>cprev<CR>zz", { desc = "Quickfix Prev (centered)" })

-- helpers to toggle qf/loclist windows
-- local function is_open(kind)
-- 	for _, win in ipairs(vim.fn.getwininfo()) do
-- 		if kind == "qf" and win.quickfix == 1 then
-- 			return true
-- 		end
-- 		if kind == "loc" and win.loclist == 1 then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end
--
-- local function toggle_qf()
-- 	if is_open("qf") then
-- 		vim.cmd.cclose()
-- 	else
-- 		vim.cmd.copen()
-- 	end
-- end
-- vim.keymap.set("n", "<leader>cq", toggle_qf, { desc = "Quickfix Toggle" })

-- ========== Developer Essentials ==========

-- Yank entire file to clipboard (no feedback)
vim.keymap.set("n", "<leader>ya", ":%y+<CR>", { desc = "Yank whole file" })

-- keep half-page moves centered
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })

-- keep search jumps centered and unfolded
vim.keymap.set("n", "n", "nzzzv", { noremap = true, silent = true })
vim.keymap.set("n", "N", "Nzzzv", { noremap = true, silent = true })

-- Leave cursor where it is when appending a line
vim.keymap.set("n", "J", "mzJ`z", { noremap = true, silent = true })

-- Stay in visual mode while indenting
vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true })

-- Move selected lines while staying in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

-- Enable save in vertical insert mode
vim.keymap.set("i", "<C-c>", "<Esc>", { noremap = true, silent = true })

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("i", "<C-h>", "<C-w>") -- CTRL+backspace

vim.keymap.set(
	"n",
	"<leader>H",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Substitute (replace) word under cursor in whole file" }
)

-- Copy current file name
vim.keymap.set("n", "<leader>cn", function()
	vim.fn.setreg("+", vim.fn.expand("%:t"))
	print("Copied filename: " .. vim.fn.expand("%:t"))
end, { noremap = true, silent = true })

-- Copy path relative to current working directory
vim.keymap.set("n", "<leader>cp", function()
	vim.fn.setreg("+", vim.fn.expand("%"))
	print("Copied path: " .. vim.fn.expand("%"))
end, { noremap = true, silent = true })

-- Copy absolute path
vim.keymap.set("n", "<leader>cP", function()
	vim.fn.setreg("+", vim.fn.expand("%:p"))
	print("Copied absolute path: " .. vim.fn.expand("%:p"))
end, { noremap = true, silent = true })

-- Show hidden characters (good for debugging indentation)
vim.opt.list = true
vim.opt.listchars = { tab = "→ ", trail = "·", nbsp = "␣" }

-- Auto reload files changed outside nvim
vim.opt.autoread = true
vim.cmd("au FocusGained,BufEnter * checktime")

-- Visual mode: paste over selection without overwriting the unnamed register
vim.keymap.set("x", "<leader>p", '"_dP', { noremap = true, silent = true })

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Always normalize to LF line endings
-- vim.api.nvim_create_autocmd({ "BufRead", "BufWritePre" }, {
--   pattern = "*",
--   command = "set ff=unix",
-- })

vim.g.dotnet_errors_only = true
vim.g.dotnet_show_project_file = false

-- ========== Diagnostics ==========
vim.o.updatetime = 50 -- 0.05 seconds idle time before CursorHold triggers

-- toggle virtual_text on/off
vim.keymap.set("n", "<leader>dt", function()
	local vt = vim.diagnostic.config().virtual_text
	if vt == false then
		vim.diagnostic.config({ virtual_text = true })
		print("diagnostic virtual_text = ON")
	else
		vim.diagnostic.config({ virtual_text = false })
		print("diagnostic virtual_text = OFF")
	end
end, { desc = "Toggle diagnostics virtual_text" })

vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		vim.diagnostic.open_float(nil, { focus = false })
	end,
})

-- Background color for DAP cursorline
vim.api.nvim_set_hl(0, "DapStoppedLine", {
	bg = "#52503b",
})
