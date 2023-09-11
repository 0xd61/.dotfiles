{ config, pkgs, unstable, ...}:
let
  common-packages = import ./packages.nix { pkgs = pkgs; };
in
{
  imports = [
    ./common.nix
  ];

  boot.kernelPackages = unstable.linuxPackages_xanmod_latest;
  boot.loader.systemd-boot.enable = false;

  # Lower GRUB resolution for faster rendering
  boot.loader.grub.gfxmodeEfi = "1024x768";

  boot.loader.grub = {
    enable = true;
    version = 2;
    efiSupport = true;
    enableCryptodisk = true;
    device = "nodev";
  };

  systemd.network.networks = let
    networkConfig = {
      DHCP = "yes";
      DNSSEC = "allow-downgrade";
      DNSOverTLS = "no";
      DNS = [ "45.90.28.183" "45.90.30.183" "1.1.1.3"];
    };
  in {
    # Config for all useful interfaces
    "40-wired" = {
      enable = true;
      name = "en*";
      inherit networkConfig;
      dhcpV4Config.RouteMetric = 1024; # Better be explicit
    };
    "40-wireless" = {
      enable = true;
      name = "wl*";
      inherit networkConfig;
      dhcpV4Config.RouteMetric = 2048; # Prefer wired
    };
    "50-zerotier" = {
      enable = true;
      name = "ztc3qrtb6r";
      networkConfig = {
        DHCP = "no";
        DNSSEC = "allow-downgrade";
        DNSOverTLS = "no";
        DNS = [ "10.0.1.80" ];
        Domains = "~avantys.de ~143.144.10.in-addr.arpa";
      };
      extraConfig = ''
        ConfigureWithoutCarrier=true
        KeepConfiguration=static
      '';
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = common-packages ++ [
    pkgs.sublime-merge
    pkgs.remmina
    pkgs.obsidian
    pkgs.testdisk
    pkgs.pigz
    pkgs.update-systemd-resolved
  ];

  # for printer sharing
  services.avahi = {
    enable = true;
    publish.enable = true;
    publish.userServices = true;
  };

  services.printing = {
    enable = true;
    drivers = [ pkgs.brlaser ];
    browsing = true;
    listenAddresses = [ "0.0.0.0:631" ];
    allowFrom = [ "localhost" "192.168.20.*" ];
  };

  # Open ports in the firewall.           # cups
  networking.firewall.allowedTCPPorts = [ 631       ];
  networking.firewall.allowedUDPPorts = [ 631 8888 51820];

  services.teamviewer.enable = true;

  services.xrdp.enable = true;

  swapDevices = [
    {
      device = "/swapfile";
      size = 1024 * 8;
    }
  ];

#  virtualisation.docker.daemon.settings = {
#    data-root = "/media/docker";
#  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
