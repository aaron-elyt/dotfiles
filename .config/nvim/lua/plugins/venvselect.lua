return {
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
      "mfussenegger/nvim-dap-python", -- Optional: for debugging support
    },
    opts = {
      search = true, -- Enable searching for venvs in the workspace
      name = { ".venv", "venv" }, -- Names of venv directories to look for
      auto_refresh = true, -- Automatically refresh the venv list on startup
      dap_enabled = true, -- Enable nvim-dap integration
      anaconda = { python_executable = "python" }, -- Adjust if using Anaconda
      notify_user_on_activate = true, -- Notify when a venv is activated
      -- Additional configuration options can be added here
    },
    config = function(_, opts)
      require("venv-selector").setup(opts)

      -- Automatically activate the cached venv when entering a project
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          require("venv-selector").retrieve_from_cache()
        end,
      })
    end,
  },
}
