local wezterm = require 'wezterm'

local mux = wezterm.mux
local act = wezterm.action

local config = wezterm.config_builder()

config.font = wezterm.font('Input Mono', {weight = 'Regular'})

config.color_scheme = 'neobones_dark'

-- start a connect session by default
-- to be able to save the session state.
config.unix_domains = {
  {
    name = 'unix',
  },
}

config.default_gui_startup_args = { 'connect', 'unix' }


return config
