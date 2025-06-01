{ config, pkgs, ...}:
let
  common-packages = import ./packages.nix { pkgs = pkgs; };
in
{
  imports = [
    ./common.nix
  ];

  networking.wireless.networks = {
    "WIFI@DB" = {};
    "KroneWLAN" = {};
    "Fb590_52_E" = {
      pskRaw = "1177aa2ef3bc66732e3afa0297eb1dc2bf4858ac7914313b3a557b5036d679b5";
    };
    "Etter-Agro" = {
      pskRaw = "a46dfce14dfce1fcaf49fd9fad50bc0fb0942417861a0b94fc0f1e38ca225697";
    };
    "405 Wi-Fi not allowed" = {
      pskRaw = "06da83698df67a3061dab1a5b5822932534035013b7d63b0fc6786131fbffafa";
    };
  };

  time.hardwareClockInLocalTime = true;

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];
  virtualisation.virtualbox.host.enableExtensionPack = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = common-packages ++ [
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
