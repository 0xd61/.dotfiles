local ls = require("luasnip")

-- Misc
vim.keymap.set({ "", "!" }, "<C-g>", "<esc><esc>", { noremap = true, silent = true, desc = "<ESC>" })
vim.keymap.set({ "i" }, "jk", "<esc>", { noremap = true, silent = true, desc = "<ESC>" })
vim.keymap.set({ "", "!" }, "<A-x>", "<esc>:", { noremap = true, desc = "Enter command mode" })

-- Navigation
vim.keymap.set({ "", "!" }, "<C-Up>", "<esc>{", { noremap = true, desc = "Up faster" })
vim.keymap.set({ "", "!" }, "<C-Down>", "<esc>}", { noremap = true, desc = "Down faster" })
vim.keymap.set({ "", "!" }, "<C-Left>", "<esc>b", { noremap = true, desc = "Left faster" })
vim.keymap.set({ "", "!" }, "<C-Right>", "<esc>w", { noremap = true, desc = "right faster" })

vim.keymap.set({ "", "!" }, "<C-S-Up>", "<esc>gg", { noremap = true, desc = "Up top" })
vim.keymap.set({ "", "!" }, "<C-S-Down>", "<esc>G", { noremap = true, desc = "Down bottom" })
vim.keymap.set({ "", "!" }, "<C-S-Left>", "<esc>0", { noremap = true, desc = "Beginning of line" })
vim.keymap.set({ "", "!" }, "<C-S-Right>", "<esc>$", { noremap = true, desc = "End of line" })

vim.keymap.set({ "", "!" }, "<A-w>", "<esc><C-w>w", { noremap = true, desc = "Move to other window" })

vim.keymap.set({ "", "!" }, "<A-t>", "<C-]>", { noremap = true, desc = "Jump to tag" })
vim.keymap.set({ "", "!" }, "<A-S-t>", "<C-t>", { noremap = true, desc = "Jump back up the tag stack" })


vim.keymap.set({ "", "!" }, "<A-c>", "<cmd>CtagHeaderToggle<cr>", { noremap = true, desc = "Jump back up the tag stack" })


-- Editor
vim.keymap.set({ "", "!" }, "<C-k>", "d$", { noremap = true, desc = "Kill line" })
vim.keymap.set({ "", "!" }, "<A-s>", "<cmd>w<cr>", { noremap = true, desc = "Save buffer" })
vim.keymap.set({ "", "!" }, "<A-S-s>", "<cmd>MakeDirSave<cr>", { noremap = true, desc = "Create dir and save buffer" })
vim.keymap.set({ "v" }, "c", ":norm 0i", { noremap = true, desc = "Comment/uncomment region" })

-- Telescope
vim.keymap.set({ "", "!" }, "<A-b>", "<cmd>Telescope buffers<cr>", { noremap = true, desc = "Open buffers" })
vim.keymap.set({ "", "!" }, "<A-S-b>", "<cmd>vsp .scratch<cr>", { noremap = true, desc = "Open scratch buffer in new window" })
vim.keymap.set({ "", "!" }, "<A-k>", "<cmd>bd<cr>", { noremap = true, desc = "Close buffer" })
vim.keymap.set({ "", "!" }, "<A-y>", "<cmd>Telescope registers<cr>", { noremap = true, desc = "Open registers" })
vim.keymap.set({ "", "!" }, "<A-f>", "<cmd>Telescope fd<cr>", { noremap = true, desc = "Open files" })
vim.keymap.set({ "", "!" }, "<A-g>", "<cmd>Telescope live_grep<cr>", { noremap = true, desc = "Search in files" })

-- Autocomplete/Snippets
vim.keymap.set({"i", "s"}, "<C-[>", function() ls.jump( 1) end, {noremap = true, silent = true, desc = "Jump forward in snippet" })
vim.keymap.set({"i", "s"}, "<C-]>", function() ls.jump(-1) end, {noremap = true, silent = true, desc = "Jump backward in snippet"})

-- Windows

-- Terminal
vim.keymap.set({ "", "!" }, "<A-n>", "<cmd>terminal<cr>", { noremap = true, desc = "Open terminal" })
vim.keymap.set({ "t" }, "<esc>", "<C-\\><C-n>", { noremap = true, desc = "Open terminal" })
vim.keymap.set({ "", "!" }, "<A-m>", "<cmd>make<cr>", { noremap = true, desc = "Run make command" })

-- Exit
vim.keymap.set({ "" }, "<A-q>", "<cmd>q<cr>", { noremap = true, desc = "Close nvim" })
vim.keymap.set({ "" }, "<A-S-q>", "<cmd>q!<cr>", { noremap = true, desc = "Force close nvim" })
