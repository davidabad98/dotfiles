-- lua/plugins/busy.lua
return {
  "davidabad98/nvim-busy.nvim",
  lazy     = false,
  priority = 900,
  config = function()
    require("busy").setup({
      animation = "dots",
      speed_ms = 80,
      position = "bottom-left",
      text = " loading",
      blend = 0,
      lsp = {
        enabled = true,
        watch_progress = true,
        watch_requests = true,
      },
      telescope = {
        enabled = true,
        animate_counter = true,
      },
    })
  end,
}
