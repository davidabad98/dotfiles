-- Bootstrap lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim plugins
require("lazy").setup({
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "lua", "vim", "vimdoc", "query" }, -- add languages you need
        highlight = { enable = true },
      }
    end,
  },

  -- Catppuccin theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "macchiato", -- latte, frappe, macchiato, mocha
      })
      vim.cmd.colorscheme "catppuccin"
    end,
  },
})

-- ========== Basic Settings ==========
vim.opt.number = true          -- Show line numbers
vim.opt.relativenumber = true  -- Relative numbers for quick jumps
vim.opt.tabstop = 4            -- Tab = 4 spaces
vim.opt.shiftwidth = 4         -- Indentation = 4 spaces
vim.opt.expandtab = true       -- Convert tabs to spaces
vim.opt.smartindent = true     -- Auto-indent new lines

vim.opt.wrap = false           -- Don’t wrap long lines
vim.opt.cursorline = true      -- Highlight current line
vim.opt.scrolloff = 8          -- Keep cursor away from edges
vim.opt.signcolumn = "yes"     -- Always show sign column

-- Always save files with Unix line endings
vim.opt.fileformat = "unix"
vim.opt.fileformats = { "unix", "dos" }

-- ========== Search ==========
vim.opt.ignorecase = true      -- Case-insensitive search...
vim.opt.smartcase = true       -- ...unless capital letters in query
vim.opt.hlsearch = true        -- Highlight search results
vim.opt.incsearch = true       -- Show matches while typing

-- ========== Clipboard ==========
vim.opt.clipboard = "unnamedplus" -- Use system clipboard

-- ========== UI ==========
vim.opt.termguicolors = true   -- Enable 24-bit colors
vim.opt.splitbelow = true      -- Split below
vim.opt.splitright = true      -- Split right
vim.opt.colorcolumn = '88'     -- Enable vertical ruler line

-- ========== Keymaps ==========
local map = vim.keymap.set
map("n", "<Space>", "<Nop>", { silent = true }) -- Space as leader
vim.g.mapleader = " "

-- Quick save & quit
map("n", "<leader>w", ":w<CR>")
map("n", "<leader>q", ":q<CR>")
map("n", "<leader>x", ":x<CR>")


-- ========== Naviagtion ==========

-- Switch b/w buffers
map("n", "<S-h>", ":bprevious<CR>")
map("n", "<S-l>", ":bnext<CR>")

-- Splits
map("n", "<leader>v", ":vsplit<CR>")
map("n", "<leader>s", ":split<CR>")
map("n", "<leader>n", ":vnew<CR>")
map("n", "<leader>t", ":tabnew<CR>")

-- Window navigation with leader
map("n", "<leader>h", "<C-w>h")
map("n", "<leader>j", "<C-w>j")
map("n", "<leader>k", "<C-w>k")
map("n", "<leader>l", "<C-w>l")


-- ========== Developer Essentials ==========

-- keep half-page moves centered
vim.keymap.set('n', '<C-d>', '<C-d>zz', { noremap = true, silent = true })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { noremap = true, silent = true })

-- keep search jumps centered and unfolded
vim.keymap.set('n', 'n', 'nzzzv', { noremap = true, silent = true })
vim.keymap.set('n', 'N', 'Nzzzv', { noremap = true, silent = true })

-- Stay in visual mode while indenting
vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true })

-- Move selected lines while staying in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

-- Show hidden characters (good for debugging indentation)
vim.opt.list = true
vim.opt.listchars = { tab = "→ ", trail = "·", nbsp = "␣" }

-- Auto reload files changed outside nvim
vim.opt.autoread = true
vim.cmd("au FocusGained,BufEnter * checktime")

-- Visual mode: paste over selection without overwriting the unnamed register
vim.keymap.set('x', '<leader>p', '"_dP', { noremap = true, silent = true })

-- Always normalize to LF line endings
vim.api.nvim_create_autocmd({ "BufRead", "BufWritePre" }, {
  pattern = "*",
  command = "set ff=unix",
})
