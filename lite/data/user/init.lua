-- put user settings here
-- this module will be loaded after everything else when the application starts

local keymap = require "core.keymap"
local config = require "core.config"
local style = require "core.style"

-- light theme:
require "user.colors.kaitsh"

-- key binding:
keymap.add {
  ["alt+x"] = "core:find-command",
  ["ctrl+i"] = "core:find-file",
  ["ctrl+shift+left"] = "doc:select-to-start-of-line",
  ["ctrl+shift+right"] = "doc:select-to-end-of-line",
  ["ctrl+space"] = "markers:toggle-marker",
  ["ctrl+shift+space"] = "markers:go-to-next-marker",
  ["modal+space"] = "markers:toggle-marker",
  ["modal+m"] = "markers:go-to-next-marker",
}

config.ignore_files = {"node_modules", "^_?build", "^deps"}

-- todotreeview settings:
-- Add extra tags

-- Change display mode
config.todo_mode = "file"

-- Ignore directory and ignore specific file
table.insert(config.ignore_paths, "README.md")
