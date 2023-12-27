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
      "lukas-reineke/cmp-rg",
      "delphinus/cmp-ctags",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "piero-vic/cmp-ledger",
    },
    config = function()
      local cmp = require("cmp")

      cmp.setup {
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
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
            ["<ESC>"] = cmp.mapping.close(),
            ["<C-d>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
          },
          sources = {
            { name = 'luasnip' }, -- For luasnip users.
            { name = "ledger" }, -- for ledger completion
            { name = "path" }, -- for path completion
            { name = "buffer", 
                keyword_length = 2,
                option = {
                    get_bufnrs = function()
                        local bufs = {}
                        for _, win in ipairs(vim.api.nvim_list_wins()) do
                            bufs[vim.api.nvim_win_get_buf(win)] = true
                        end
                        return vim.tbl_keys(bufs)
                    end
                }
            }, -- for buffer word completion
            { name = "rg", keyword_length = 2 }, -- ripgrep completion
            { name = "ctags"}, -- ctags completion
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
          sync_install = true,
          highlight = { 
              enable = true,
              additional_vim_regex_highlighting = false,
          },
          indent = { enable = true },
        })

        vim.api.nvim_set_hl(0, "@text.note", { link = "Search" })
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
