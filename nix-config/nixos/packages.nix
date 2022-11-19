{ pkgs }:

with pkgs; [
  # System
  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  wget
  dwm
  dmenu
  alacritty
  acpi
  lm_sensors
  zerotierone
  wireguard-tools

  # Tools
  borgbackup
]
