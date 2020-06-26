local core = require "core"
local common = require "core.common"
local command = require "core.command"
local config = require "core.config"
local DocView = require "core.docview"

local function doc()
  return core.active_view.doc
end

local draw_line_text = DocView.draw_line_text
local highlights = {
  ["NOTE%(.-%):"] = { common.color "#F7D070" },
  ["TODO%(.-%):"] = { common.color "#BA2525" },
}

function DocView:draw_line_text(idx, x, y)
  for key, val in pairs(highlights) do
    local text = self.doc.lines[idx]
    local s, e = text:find(key)
    if s then
      local x1 = x + self:get_col_x_offset(idx, s)
      local x2 = x + self:get_col_x_offset(idx, e)
      local h = math.ceil(2 * SCALE)
      renderer.draw_rect(x1, y + self:get_line_height() - h, x2 - x1, h, val)
    end
  end

  draw_line_text(self, idx, x, y)

end

local function build_comment(type)
  local comment = doc().syntax.comment
  if not comment then return end
  local t = {comment, " ", type, "(", config.user_initials, "): "}
  return table.concat(t)
end

-- TODO: create todo and note comments
command.add(nil, {
  ["highlightcomments:add-todo"] = function()
    local doc = core.active_view.doc
    local line, col = doc:get_selection()
    local text = build_comment("TODO")
    if text then
      doc:insert(line, col, text)
      doc:set_selection(line, col + #text)
    end
  end,
  ["highlightcomments:add-note"] = function()
    local doc = core.active_view.doc
    local line, col = doc:get_selection()
    local text = build_comment("NOTE")
    if text then
      doc:insert(line, col, text)
      doc:set_selection(line, col + #text)
    end
  end,
})




