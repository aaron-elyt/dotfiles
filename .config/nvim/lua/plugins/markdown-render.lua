return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = "markdown",
  config = function()
    require("render-markdown").setup({
      -- Enable soft wrapping
      wrap = true,
      -- Hide Markdown formatting characters
      conceal = true,
      -- Automatically render markdown on open
      auto_render = true,
      -- Update render when text changes
      update_on_change = true,
    })
  end,
}
