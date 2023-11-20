-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("i", "<C-g>", "<ESC>", { noremap = true, silent = true, desc = "<ESC>" })

-- Navigation
vim.keymap.set({ "n", "v" }, "<S-Up>", "{", { noremap = true, desc = "Up faster" })
vim.keymap.set({ "n", "v" }, "<S-Down>", "}", { noremap = true, desc = "Down faster" })
vim.keymap.set({ "n", "v" }, "<S-Left>", "b", { noremap = true, desc = "Left faster" })
vim.keymap.set({ "n", "v" }, "<S-Right>", "w", { noremap = true, desc = "right faster" })

vim.keymap.set({ "n", "v" }, "<C-S-Up>", "gg", { noremap = true, desc = "Up top" })
vim.keymap.set({ "n", "v" }, "<C-S-Down>", "G", { noremap = true, desc = "Down bottom" })
vim.keymap.set({ "n", "v" }, "<C-S-Left>", "0", { noremap = true, desc = "Beginning of line" })
vim.keymap.set({ "n", "v" }, "<C-S-Right>", "$", { noremap = true, desc = "End of line" })

-- Save file
vim.keymap.set("n", "<A-s>", "<cmd>w<cr>", { noremap = true, desc = "Save window" })
