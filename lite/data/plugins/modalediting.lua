--[[
Inspired by a327ex: https://github.com/a327ex/lite-plugins/blob/master/plugins/modalediting.lua

Press ESCAPE to go into normal mode, in this mode you can move around using the "modal+" keybindings
you find at the bottom of this file. Press I to go back to insert mode. While this plugin is inspired
by vim, this is not a vim emulator, it only has the most basic movement functions that vim does.
]]--

local core = require "core"
local command = require "core.command"
local CommandView = require "core.commandview"
local keymap = require "core.keymap"
local DocView = require "core.docview"
local style = require "core.style"
local config = require "core.config"
local common = require "core.common"
local translate = require "core.doc.translate"

local mode = "command"

local function dv()
  return core.active_view
end

local function doc()
  return core.active_view.doc
end

local function has_commandview()
  return core.active_view:is(CommandView)
end

local modkey_map = {
  ["left ctrl"]   = "ctrl",
  ["right ctrl"]  = "ctrl",
  ["left shift"]  = "shift",
  ["right shift"] = "shift",
  ["left alt"]    = "alt",
  ["right alt"]   = "altgr",
}

local modkeys = { "ctrl", "alt", "altgr", "shift" }

local function key_to_stroke(k)
  local stroke = ""
  for _, mk in ipairs(modkeys) do
    if keymap.modkeys[mk] then
      stroke = stroke .. mk .. "+"
    end
  end
  return stroke .. k
end

function keymap.on_key_pressed(k)
  local mk = modkey_map[k]
  if mk then
    keymap.modkeys[mk] = true
    -- work-around for windows where `altgr` is treated as `ctrl+alt`
    if mk == "altgr" then
      keymap.modkeys["ctrl"] = false
    end
  else
    local stroke = key_to_stroke(k)
    local commands

    if has_commandview() or mode == "insert" then
      commands = keymap.map[stroke]
    elseif mode == "command" then
      commands = keymap.map["modal+" .. stroke]
      -- when no command found, we fall back to insert mode (default) commands
      if not commands then
      -- we change to insert mode. Otherweise
        commands = keymap.map[stroke]
      end
    end

    if commands then
      for _, cmd in ipairs(commands) do
        local performed = command.perform(cmd)
        if performed then break end
      end
      return true
    end

    -- we don't want to perform any action (key insert) when a command isn't found in movement mode
    if not has_commandview() and mode == "command" then
      return true
    end
  end
  return false
end

local draw_line_body = DocView.draw_line_body

function DocView:draw_line_body(idx, x, y)
  local line, col = self.doc:get_selection()
  draw_line_body(self, idx, x, y)

  if not has_commandview() and mode == "command" then
    if line == idx and core.active_view == self
    and system.window_has_focus() then
      local lh = self:get_line_height()
      local x1 = x + self:get_col_x_offset(line, col)
      local w = self:get_font():get_width(" ")
      renderer.draw_rect(x1, y, w, lh, style.caret)
    end
  end
end

command.add(nil, {
  ["modalediting:switch-to-normal-mode"] = function()
    mode = "command"
    command.perform("doc:select-none")
  end,

  ["modalediting:switch-to-insert-mode"] = function()
    mode = "insert"
  end,

  ["modalediting:insert-at-start-of-line"] = function()
    mode = "insert"
    command.perform("doc:move-to-start-of-line")
  end,

  ["modalediting:insert-at-end-of-line"] = function()
    mode = "insert"
    command.perform("doc:move-to-end-of-line")
  end,

  ["modalediting:insert-at-next-char"] = function()
    mode = "insert"
    local line, col = doc():get_selection()
    local next_line, next_col = translate.next_char(doc(), line, col)
    if line ~= next_line then
      doc():move_to(translate.end_of_line, dv())
    else
      if doc():has_selection() then
        local _, _, line, col = doc():get_selection(true)
        doc():set_selection(line, col)
      else
        doc():move_to(translate.next_char)
      end
    end
  end,

  ["modalediting:insert-on-newline-below"] = function()
    mode = "insert"
    command.perform("doc:newline-below")
  end,

  ["modalediting:insert-on-newline-above"] = function()
    mode = "insert"
    command.perform("doc:newline-above")
  end,

  ["modalediting:delete-line"] = function()
    if doc():has_selection() then
      local text = doc():get_text(doc():get_selection())
      system.set_clipboard(text)
      doc():delete_to(0)
    else
      local line, col = doc():get_selection()
      doc():move_to(translate.start_of_line, dv())
      doc():select_to(translate.end_of_line, dv())
      if doc():has_selection() then
        local text = doc():get_text(doc():get_selection())
        system.set_clipboard(text)
        doc():delete_to(0)
      end
      local line1, col1, line2 = doc():get_selection(true)
      append_line_if_last_line(line2)
      doc():remove(line1, 1, line2 + 1, 1)
      doc():set_selection(line1, col1)
    end
  end,

  ["modalediting:delete-to-end-of-line"] = function()
    if doc():has_selection() then
      local text = doc():get_text(doc():get_selection())
      system.set_clipboard(text)
      doc():delete_to(0)
    else
      doc():select_to(translate.end_of_line, dv())
      if doc():has_selection() then
        local text = doc():get_text(doc():get_selection())
        system.set_clipboard(text)
        doc():delete_to(0)
      end
    end
  end,

  ["modalediting:delete-word"] = function()
    if doc():has_selection() then
      local text = doc():get_text(doc():get_selection())
      system.set_clipboard(text)
      doc():delete_to(0)
    else
      doc():select_to(translate.next_word_boundary, dv())
      if doc():has_selection() then
        local text = doc():get_text(doc():get_selection())
        system.set_clipboard(text)
        doc():delete_to(0)
      end
    end
  end,

  ["modalediting:delete-char"] = function()
    if doc():has_selection() then
      local text = doc():get_text(doc():get_selection())
      system.set_clipboard(text)
      doc():delete_to(0)
    else
      doc():select_to(translate.next_char, dv())
      if doc():has_selection() then
        local text = doc():get_text(doc():get_selection())
        system.set_clipboard(text)
        doc():delete_to(0)
      end
    end
  end,

  ["modalediting:paste"] = function()
    local line, col = doc():get_selection()
    local indent = doc().lines[line]:match("^[\t ]*")
    doc():insert(line, math.huge, "\n")
    doc():set_selection(line + 1, math.huge)
    doc():text_input(indent .. system.get_clipboard():gsub("\r", ""))
  end,

  ["modalediting:copy"] = function()
    if doc():has_selection() then
      local text = doc():get_text(doc():get_selection())
      system.set_clipboard(text)
      local line, col = doc():get_selection()
      doc():move_to(function() return line, col end, dv())
    else
      local line, col = doc():get_selection()
      doc():move_to(translate.start_of_line, dv())
      doc():move_to(translate.next_word_boundary, dv())
      doc():select_to(translate.end_of_line, dv())
      if doc():has_selection() then
        local text = doc():get_text(doc():get_selection())
        system.set_clipboard(text)
      end
      doc():move_to(function() return line, col end, dv())
    end
  end,

  ["modalediting:find"] = function()
    mode = "insert"
    command.perform("find-replace:find")
  end,

  ["modalediting:replace"] = function()
    mode = "insert"
    command.perform("find-replace:replace")
  end,

  ["modalediting:go-to-line"] = function()
    mode = "insert"
    command.perform("doc:go-to-line")
  end,

  ["modalediting:close"] = function()
    mode = "insert"
    command.perform("root:close")
  end,

  ["modalediting:end-of-line"] = function()
    if doc():has_selection() then
      doc():select_to(translate.end_of_line, dv())
    else
      command.perform("doc:move-to-end-of-line")
    end
  end,

  ["modalediting:command-finder"] = function()
    mode = "insert"
    command.perform("core:command-finder")
  end,

  ["modalediting:file-finder"] = function()
    mode = "insert"
    command.perform("core:file-finder")
  end,

  ["modalediting:open-file"] = function()
    mode = "insert"
    command.perform("core:open-file")
  end,

  ["modalediting:new-doc"] = function()
    mode = "insert"
    command.perform("core:new-doc")
  end,

  ["modalediting:indent"] = function()
    if doc():has_selection() then
      local line, col = doc():get_selection()
      local line1, col1, line2, col2 = doc():get_selection(true)
      for i = line1, line2 do
        doc():move_to(function() return i, 1 end, dv())
        doc():move_to(translate.start_of_line, dv())
        command.perform("doc:indent")
      end
      doc():move_to(function() return line, col end, dv())
    else
      local line, col = doc():get_selection()
      doc():move_to(translate.start_of_line, dv())
      command.perform("doc:indent")
      doc():move_to(function() return line, col end, dv())
    end
  end,
})

keymap.add {
  ["modal+ctrl+f"] = "modalediting:find",
  ["modal+i"] = "modalediting:switch-to-insert-mode",
  ["modal+shift+i"] = "modalediting:insert-at-start-of-line",
  ["modal+a"] = "modalediting:insert-at-next-char",
  ["modal+shift+a"] = "modalediting:insert-at-end-of-line",
  ["modal+o"] = "modalediting:insert-on-newline-below",
  ["modal+shift+o"] = "modalediting:insert-on-newline-above",

  ["modal+k"] = "doc:move-to-previous-line",
  ["modal+j"] = "doc:move-to-next-line",
  ["modal+h"] = "doc:move-to-previous-char",
  ["modal+l"] = "doc:move-to-next-char",
  ["modal+shift+k"] = "doc:move-to-previous-block-start",
  ["modal+shift+j"] = "doc:move-to-next-block-end",
  ["modal+shift+h"] = "doc:move-to-previous-word-start",
  ["modal+shift+l"] = "doc:move-to-next-word-end",
  ["modal+x"] = "doc:backspace",
  ["modal+0"] = "doc:move-to-start-of-line",
  ["modal+shift+4"] = "doc:move-to-end-of-line",

  ["modal+u"] = "doc:undo",
  ["modal+shift+r"] = "doc:redo",

  ["escape"] = { "command:escape", "modalediting:switch-to-normal-mode" },
}


