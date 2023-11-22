local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

local spec = {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim"
    },
  },
  {
    "ap/vim-css-color",
  },
  {
      "ledger/vim-ledger",
  },
  {
    "hrsh7th/nvim-cmp",
    -- event = 'InsertEnter',
    event = "VeryLazy",
    dependencies = {
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-vsnip",
      "piero-vic/cmp-ledger",
    },
    config = function()
      local cmp = require("cmp")

      cmp.setup {
        snippet = {
          expand = function(args)
            -- For `ultisnips` user.
            vim.fn["vsnip#anonymous"](args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ["<Tab>"] = function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
                fallback()
              end
            end,
            ["<S-Tab>"] = function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              else
                fallback()
              end
            end,
            ["<CR>"] = cmp.mapping.confirm { select = true },
            ["<C-e>"] = cmp.mapping.abort(),
            ["<Esc>"] = cmp.mapping.close(),
            ["<C-d>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
          },
          sources = {
            { name = "vsnip" }, 
            { name = "ledger" }, -- for ledger completion
            { name = "path" }, -- for path completion
            { name = "buffer", keyword_length = 2 }, -- for buffer word completion
          },
          completion = {
            keyword_length = 1,
            completeopt = "menu,noselect",
          },
          view = {
            entries = "custom",
          },
        }
   end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "VeryLazy",
    config = function () 
      local configs = require("nvim-treesitter.configs")

      configs.setup({
          ensure_installed = {"bash",
                              "bitbake",
                              "c",
                              "cmake",
                              "diff",
                              "go",
                              "html",
                              "javascript",
                              "json",
                              "jsonc",
                              "ledger",
                              "lua",
                              "markdown",
                              "markdown_inline",
                              "python",
                              "query",
                              "regex",
                              "toml",
                              "vim",
                              "vimdoc",
                              "yaml",
                             },
          sync_install = false,
          highlight = { enable = true },
          indent = { enable = false },
        })
    end,
  }
}

local opts = {
  ui = {
    border = "rounded",
    title = "Plugin Manager",
    title_pos = "center",
  },
}

require("lazy").setup(spec, opts)
