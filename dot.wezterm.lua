local wezterm = require 'wezterm'

local mux = wezterm.mux
local act = wezterm.action

local config = wezterm.config_builder()

config.font = wezterm.font('Input Mono', {weight = 'Regular'})

config.colors = {
  -- The default text color
  foreground = 'silver',
  -- The default background color
  background = '#013137',

  -- -- Overrides the cell background color when the current cell is occupied by the
  -- -- cursor and the cursor style is set to Block
  -- cursor_bg = '#52ad70',
  -- -- Overrides the text color when the current cell is occupied by the cursor
  -- cursor_fg = 'black',
  -- -- Specifies the border color of the cursor when the cursor style is set to Block,
  -- -- or the color of the vertical or horizontal bar when the cursor style is set to
  -- -- Bar or Underline.
  -- cursor_border = '#52ad70',

  -- -- the foreground color of selected text
  -- selection_fg = 'black',
  -- -- the background color of selected text
  -- selection_bg = '#fffacd',

  -- -- The color of the scrollbar "thumb"; the portion that represents the current viewport
  -- scrollbar_thumb = '#222222',

  -- -- The color of the split lines between panes
  -- split = '#444444',
}

-- and finally, return the configuration to wezterm
return config
