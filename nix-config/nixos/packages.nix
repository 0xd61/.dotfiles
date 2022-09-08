{ pkgs }:

with pkgs; [
  # System
  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  wget
  git
  #st
  dwm
  dmenu
  alacritty
  #xwayland
  #bemenu
  #wl-clipboard
  #dwl
  #yambar
  #inotify-tools
  #foot
  acpi
  lm_sensors
  zerotierone

  # Tools
  borgbackup
  fd
  gnupg
  htop
  jq
  zip
  unzip
  xz
  man-pages
  man-pages-posix

  #Virtualisation
  qemu
  virt-viewer
  spice-gtk
]
