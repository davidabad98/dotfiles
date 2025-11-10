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

-- ========== Clipboard ==========
vim.opt.clipboard = "unnamedplus" -- Use system clipboard

-- ========== UI ==========
vim.opt.termguicolors = true -- Enable 24-bit colors
vim.opt.splitbelow = true -- Split below
vim.opt.splitright = true -- Split right
vim.opt.colorcolumn = "88" -- Enable vertical ruler line

-- ========== Keymaps ==========

-- Quick save & quit
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")
vim.keymap.set("n", "<leader>x", ":x<CR>")

-- ========== Naviagtion ==========

-- Switch b/w buffers
vim.keymap.set("n", "<S-h>", ":bprevious<CR>")
vim.keymap.set("n", "<S-l>", ":bnext<CR>")

-- Splits
vim.keymap.set("n", "<leader>v", ":vsplit<CR>")
vim.keymap.set("n", "<leader>s", ":split<CR>")
vim.keymap.set("n", "<leader>n", ":vnew<CR>")
vim.keymap.set("n", "<leader>t", ":tabnew<CR>")

-- Window navigation with leader
vim.keymap.set("n", "<leader>h", "<C-w>h")
vim.keymap.set("n", "<leader>j", "<C-w>j")
vim.keymap.set("n", "<leader>k", "<C-w>k")
vim.keymap.set("n", "<leader>l", "<C-w>l")

-- ========== Quickfix ==========
vim.keymap.set("n", "<C-j>", ":cnext<CR>", { desc = "Quickfix Next" })
vim.keymap.set("n", "<C-k>", ":cprev<CR>", { desc = "Quickfix Prev" })

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
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- Show hidden characters (good for debugging indentation)
vim.opt.list = true
vim.opt.listchars = { tab = "→ ", trail = "·", nbsp = "␣" }

-- Auto reload files changed outside nvim
vim.opt.autoread = true
vim.cmd("au FocusGained,BufEnter * checktime")

-- Visual mode: paste over selection without overwriting the unnamed register
vim.keymap.set("x", "<leader>p", '"_dP', { noremap = true, silent = true })

-- Always normalize to LF line endings
-- vim.api.nvim_create_autocmd({ "BufRead", "BufWritePre" }, {
--   pattern = "*",
--   command = "set ff=unix",
-- })

-- ========== Diagnostics ==========
vim.o.updatetime = 50 -- 0.05 seconds idle time before CursorHold triggers

-- configure diagnostic display
vim.diagnostic.config({
	-- virtual_text = false, -- disable inline text
	-- signs = true,
	-- underline = true,
	-- update_in_insert = false,
	severity_sort = true,
})

vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		vim.diagnostic.open_float(nil, { focus = false })
	end,
})

-- ========== Design ==========
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
