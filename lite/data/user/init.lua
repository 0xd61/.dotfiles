-- put user settings here
-- this module will be loaded after everything else when the application starts

local keymap = require "core.keymap"
local config = require "core.config"
local style = require "core.style"

-- light theme:
require "user.colors.kaitsh"

-- key binding:
keymap.add {
  ["ctrl+z"] = "doc:undo",
  ["ctrl+shift+z"] = "doc:redo",
  ["alt+x"] = "core:find-command",
  ["ctrl+shift+p"] = "core:set-project-root",
  ["ctrl+i"] = "core:find-file",
  ["ctrl+space"] = "markers:toggle-marker",
  ["ctrl+shift+space"] = "markers:go-to-next-marker",
  ["modal+space"] = "markers:toggle-marker",
  ["modal+m"] = "markers:go-to-next-marker",
  ["ctrl+m"] = "markers:go-to-next-marker",
  ["ctrl+shift+l"] = "doc:duplicate-lines",
  ["ctrl+shift+d"] = "doc:delete-lines",
  ["modal+c"] = "doc:toggle-line-comments",
  ["modal+d"] = "doc:delete-lines",

  ["ctrl+t"] = "treeview:toggle",
  ["ctrl+shift+t"] = "todotreeview:toggle",

  ["alt+t"] = "highlightcomments:add-todo",
  ["alt+y"] = "highlightcomments:add-note",

  ["alt+shift+left"] = "root:split-left",
  ["alt+shift+right"] = "root:split-right",
  ["alt+shift+up"] = "root:split-up",
  ["alt+shift+down"] = "root:split-down",
  ["alt+left"] = "root:switch-to-left",
  ["alt+right"] = "root:switch-to-right",
  ["alt+up"] = "root:switch-to-up",
  ["alt+down"] = "root:switch-to-down",

  ["ctrl+."] = "macro:play",
  ["ctrl+shift+."] = "macro:toggle-record",
  ["alt+."] = "console:run",
  ["alt+shift+."] = "console:toggle",

  ["ctrl+-"] = "scale:decrease",
  ["ctrl++"] = "scale:increase",
}

config.indent_size = 4
config.project_max_files = 10000
config.project_scan_rate = 30
config.fps = 30
config.ignore_files = {"^node_modules$", "^_build$", "^deps$", "^.git$"}
config.mouse_wheel_scroll = 80 * SCALE
config.temp_file_prefix = "/tmp/.lite_temp_"

-- highlightcomments settings:
config.user_initials = "dgl"

-- todotreeview settings:
-- Add extra tags

-- Change display mode
config.todo_mode = "file"

-- Ignore directory and ignore specific file
table.insert(config.ignore_paths, "README.md")

config.draw_whitespace = false
