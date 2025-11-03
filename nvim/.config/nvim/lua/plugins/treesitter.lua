  -- Treesitter
  return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "lua", "vim", "vimdoc", "query", "javascript", "python",
                    "c_sharp", "razor", "html", "sql", "json", "markdown", 
                    "markdown_inline" }, -- add languages you need
        highlight = { enable = true },
        indent = { enable = true },
      }
    end,
  }
