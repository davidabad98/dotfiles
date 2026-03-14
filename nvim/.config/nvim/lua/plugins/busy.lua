-- lua/plugins/busy.lua
-- Local development spec for nvim-busy.nvim.
-- Points lazy.nvim at the local plugin directory instead of GitHub.
-- Once published, replace `dir` with the GitHub source:
--   "yourusername/nvim-busy.nvim"
return {
  dir      = vim.fn.expand("~/projects/nvim-busy.nvim"),
  name     = "nvim-busy",
  lazy     = false,   -- load at startup; the plugin decides when to act
  priority = 900,     -- load before LSP config (colorscheme is 1000)
  config = function()
    require("busy").setup({
      animation = "dots",
      speed_ms = 80,
      position = "bottom-left",
      text = " loading",
      blend = 0,
      lsp = {
        enabled = true,
        watch_progress = true,  -- Phase 2: show bar during LSP indexing
        watch_requests = true,  -- Phase 3: precise clear via LspRequest autocmd
      },
      telescope = {
        enabled = true,
        animate_counter = true, -- Phase 4: spinner in Telescope prompt
      },
    })
  end,
}
