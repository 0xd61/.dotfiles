local fn = vim.fn
local api = vim.api

local Utils = {}
Utils.__index = Utils

function Utils:insert_text(text)
    local row, col = unpack(api.nvim_win_get_cursor(0))
    api.nvim_buf_set_text(0, row, col, row, col, { text })
end

api.nvim_create_user_command(
    'Today',
    function(args)
        Utils.insert_text(os.date("%Y/%M/%d"))
    end,
    { nargs = '?' }
)

api.nvim_create_user_command(
    'Todo',
    function()
        Utils.insert_text("// TODO(dgl): ")
    end,
    { nargs = '?' }
)

api.nvim_create_user_command(
    'Note',
    function()
        Utils.insert_text("// NOTE(dgl): ")
    end,
    { nargs = '?' }
)


