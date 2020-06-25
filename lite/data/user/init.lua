-- put user settings here
-- this module will be loaded after everything else when the application starts

local keymap = require "core.keymap"
local config = require "core.config"
local style = require "core.style"

-- light theme:
require "user.colors.kaitsh"

-- key binding:
-- keymap.add { ["ctrl+escape"] = "core:quit" }

config.ignore_files = {"node_modules", "^_?build", "^deps"}

-- todotreeview settings:
-- Add extra tags

-- Change display mode
config.todo_mode = "file"

-- Ignore directory and ignore specific file
table.insert(config.ignore_paths, "README.md")
