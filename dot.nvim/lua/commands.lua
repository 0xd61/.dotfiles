local fn = vim.fn
local api = vim.api

local utils = require('utils')

api.nvim_create_user_command(
    'Today',
    function(args)
        utils.insert_text(os.date("%Y/%M/%d"))
    end,
    { nargs = '?' }
)

api.nvim_create_user_command(
    'Todo',
    function()
        utils.insert_text("// TODO(dgl): ")
    end,
    { nargs = '?' }
)

api.nvim_create_user_command(
    'Note',
    function()
        utils.insert_text("// NOTE(dgl): ")
    end,
    { nargs = '?' }
)


