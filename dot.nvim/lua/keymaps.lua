-- Misc
vim.keymap.set({ "", "!" }, "<C-g>", "<esc><esc>", { noremap = true, silent = true, desc = "<ESC>" })
vim.keymap.set({ "", "!" }, "<A-p>", "<esc>:", { noremap = true, desc = "Enter command mode" })

-- Navigation
vim.keymap.set({ "", "!" }, "<C-Up>", "{", { noremap = true, desc = "Up faster" })
vim.keymap.set({ "", "!" }, "<C-Down>", "}", { noremap = true, desc = "Down faster" })
vim.keymap.set({ "", "!" }, "<C-Left>", "b", { noremap = true, desc = "Left faster" })
vim.keymap.set({ "", "!" }, "<C-Right>", "w", { noremap = true, desc = "right faster" })

vim.keymap.set({ "", "!" }, "<C-S-Up>", "gg", { noremap = true, desc = "Up top" })
vim.keymap.set({ "", "!" }, "<C-S-Down>", "G", { noremap = true, desc = "Down bottom" })
vim.keymap.set({ "", "!" }, "<C-S-Left>", "0", { noremap = true, desc = "Beginning of line" })
vim.keymap.set({ "", "!" }, "<C-S-Right>", "$", { noremap = true, desc = "End of line" })

vim.keymap.set({ "", "!" }, "<A-w>", "<esc><C-w>w", { noremap = true, desc = "Move to other window" })

-- Editor
vim.keymap.set({ "", "!" }, "<C-k>", "d$", { noremap = true, desc = "Kill line" })
vim.keymap.set({ "", "!" }, "<A-s>", "<cmd>w<cr>", { noremap = true, desc = "Save buffer" })
vim.keymap.set({ "", "!" }, "<A-S-s>", "<cmd>silent !mkdir -p %:p:h<cr><cmd>w<cr>", { noremap = true, desc = "Create dir and save buffer" })

-- Telescope
vim.keymap.set({ "", "!" }, "<A-b>", "<cmd>Telescope buffers<cr>", { noremap = true, desc = "Open buffers" })
vim.keymap.set({ "", "!" }, "<A-S-b>", "<cmd>vsp *scratch*<cr>", { noremap = true, desc = "Open scratch buffer" })
vim.keymap.set({ "", "!" }, "<A-k>", "<cmd>bd<cr>", { noremap = true, desc = "Close buffer" })
vim.keymap.set({ "", "!" }, "<A-y>", "<cmd>Telescope registers<cr>", { noremap = true, desc = "Open registers" })
vim.keymap.set({ "", "!" }, "<A-f>", "<cmd>Telescope fd<cr>", { noremap = true, desc = "Open files" })

-- Windows

-- Terminal
vim.keymap.set({ "", "!" }, "<A-n>", "<cmd>vsp | terminal<cr>", { noremap = true, desc = "Open terminal" })
vim.keymap.set({ "t" }, "<esc>", "<C-\\><C-n>", { noremap = true, desc = "Open terminal" })
vim.keymap.set({ "", "!" }, "<A-m>", "<cmd>make<cr>", { noremap = true, desc = "Run make command" })

-- Exit
vim.keymap.set({ "" }, "<A-S-q>", "<cmd>q<cr>", { noremap = true, desc = "Close nvim" })
