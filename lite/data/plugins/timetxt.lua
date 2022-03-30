local core = require "core"
local config = require "core.config"
local style = require "core.style"
local DocView = require "core.docview"

config.timetxt_filename = "time.*%.txt$"

local default_draw_line_gutter = function() end
local default_get_gutter_width = function() return style.padding.x end


local function maybe_get_default(value, default)
  if value == nil then return default else return value end
end

local function parse_date(datetime)
  if not datetime then return end
  datetime = string.gsub(datetime, "%s+", "")

  local base_pattern = "(%d+)%-(%d+)%-(%d+)T(.*)"
  local year, month, day, tail = datetime:match(base_pattern)

  if not tail then return end

  local time, offsetsign, offset = tail:match("(.*)([%+%-])(.*)")

  if not (time and offsetsign and offset) then return end

  local time_parts = {}
  for p in (time .. ":"):gmatch("(.-):") do
    table.insert(time_parts, p)
  end

  local offset_parts = {}
  for p in (offset .. ":"):gmatch("(.-):") do
    table.insert(offset_parts, p)
  end

  local timestamp = os.time{year = year, month = month, day = day, hour = maybe_get_default(time_parts[1], 0), min = maybe_get_default(time_parts[2], 0), sec = maybe_get_default(time_parts[3], 0)}

  local offsethour = maybe_get_default(tonumber(maybe_get_default(offset_parts[1], "0")), 0)
  local offsetmin = maybe_get_default(tonumber(maybe_get_default(offset_parts[2], "0")), 0)
  local offsetsec = maybe_get_default(tonumber(maybe_get_default(offset_parts[3], "0")), 0)
  local offset = (offsethour * 60 + offsetmin) * 60 + offsetsec
  if offsetsign == "-" then offset = offset * -1 end

  return timestamp - offset
end


local function get_hours_by_line(line)
  local parts = {};
  for p in (line .. "|"):gmatch("(.-)|") do
    table.insert(parts, p)
  end

  local start = parse_date(parts[1])
  local stop = parse_date(parts[2])

  local difftime = 0
  if start and stop then
    difftime = os.difftime(stop, start)
  elseif start then
    difftime = os.difftime(os.time(), start)
  end

  local hours = math.floor(difftime / 3600)
  difftime = difftime - (hours * 3600)
  local minutes = math.floor(difftime / 60)
  difftime = difftime - (minutes * 60)
  local seconds = difftime

  return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

function DocView:draw_line_gutter(idx, x, y)
  local dv = core.active_view

  local filename = dv.doc and dv.doc.filename or ""
  if filename:match(config.timetxt_filename) then
    local color = style.line_number
    local line1, _, line2, _ = self.doc:get_selection(true)
    if idx >= line1 and idx <= line2 then
      color = style.line_number2
    end
    local yoffset = self:get_line_text_y_offset()
    x = x + style.padding.x

    local hours = get_hours_by_line(self.doc.lines[idx])

    renderer.draw_text(self:get_font(), hours, x, y + yoffset, color)
  else
    default_draw_line_gutter(self, idx, x, y)
  end
end

function DocView:get_gutter_width()
  local dv = core.active_view
  local filename = dv.doc and dv.doc.filename or ""
  if filename:match(config.timetxt_filename) then
    print("here")
    return self:get_font():get_width(os.date("%H:%M:%S")) + style.padding.x * 2
  else
    return default_get_gutter_width(self)
  end

  -- NOTE(dgl): never called
  return 0
end
