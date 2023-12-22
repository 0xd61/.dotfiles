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

api.nvim_create_user_command(
    'CtagHeaderToggle',
    function()
        local file_path = vim.fn.expand("%")
        local file_name = vim.fn.expand("%:t:r")
        local extension = vim.fn.expand("%:e")
        local err_msg = "There is no file "
        if extension == "c" or extension == "cpp" then
            local next_file = file_name .. ".h"
            local ok, result = pcall(vim.cmd, ':tag ' .. next_file)
            if not ok then
                print(err_msg .. next_file .. '\n' .. result)
            end
        elseif extension == "h" then
            local next_file = file_name .. ".c"
            local ok, result = pcall(vim.cmd, ':tag ' .. next_file)
            if not ok then
                next_file = file_name .. ".cpp"
                local ok, result = pcall(vim.cmd, ':tag ' .. next_file)
                if not ok then
                    print(err_msg .. next_file .. '\n' .. result)
                end
            end
        end
    end,
    { nargs = '?' }
)

api.nvim_create_user_command(
    'CtagUpdate',
    function()
        local ok, result = pcall(vim.cmd, '!ctags -a -u -R --extras=+f ' .. vim.fn.getcwd())
        if ok then
            print("ctags updated!\n")
        else
            print(result)
        end
    end,
    { nargs = '?' }
)

api.nvim_create_user_command(
    'MakeDirSave',
    function()
        local mkdir_cmd = "!mkdir -p %:p:h"
        if vim.g.is_windows then
            mkdir_cmd = "!mkdir %:p:h"
        end
        local ok, result = pcall(vim.cmd, mkdir_cmd)
        if ok then
            vim.cmd(":w")
        else
            print(result)
        end
    end,
    { nargs = '?' }
)

