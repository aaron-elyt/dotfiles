return {
  "catppuccin/nvim",
  lazy = true,
  name = "catppuccin1",

  opts = {
    transparent_background = true,
    integrations = {
      -- Can disable the theme for neotree so its the same color as the right panel
      neotree = true,
    },
    custom_highlights = function(colors)
      return {
        Normal = { bg = "NONE" }, -- Main background
        NormalNC = { bg = "NONE" }, -- Inactive windows
        NormalFloat = { bg = "NONE" }, -- Floating windows
        CursorLine = { bg = "NONE" },
        StatusLine = { bg = "NONE" },
        StatusLineNC = { bg = "NONE" },
        TabLineSel = { bg = "#32D1FD" },
        BufferLineBufferSelected = { fg = "#32D1FD" },
        Comment = { fg = colors.flamingo },
      }
    end,
  },
}
