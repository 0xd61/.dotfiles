{ config, pkgs, unstable, ...}:
let
  common-packages = import ./packages.nix { pkgs = pkgs; };
in
{
  imports = [
    ./common.nix
  ];

  boot.kernelPackages = unstable.linuxPackages_xanmod_latest;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = common-packages ++ [
  ];

  services.printing = {
    enable = true;
    drivers = [ pkgs.epson-escpr ];
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 1024 * 4;
    }
  ];

  services.avahi.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
