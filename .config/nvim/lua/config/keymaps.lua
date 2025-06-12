-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>e", function()
  require("mini.files").open(vim.fn.expand("%:p:h")) -- Opens the file's directory
end, { desc = "Open file in mini file" })

vim.keymap.set("n", "<leader>cb", function()
  local file = vim.fn.expand("%:p") -- Get full path of current file
  local filetype = vim.bo.filetype -- Detect file type
  local cmd

  -- Define run commands based on file type
  if filetype == "python" then
    cmd = "python3 " .. file
  elseif filetype == "javascript" then
    cmd = "node " .. file
  elseif filetype == "sh" then
    cmd = "bash " .. file
  else
    vim.notify("No run command defined for filetype: " .. filetype, vim.log.levels.ERROR)
    return
  end

  -- Open the terminal and execute the command
  require("toggleterm.terminal").Terminal:new({ cmd = cmd, direction = "horizontal" }):toggle()
end, { desc = "Run Current File in Terminal" })
-- Map Esc Esc to exit terminal mode
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    vim.api.nvim_buf_set_keymap(0, "t", "<Esc><Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, "n", "q", ":q!<CR>", { noremap = true, silent = true }) -- 'q' in normal mode
  end,
})
