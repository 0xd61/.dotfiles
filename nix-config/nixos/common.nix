{ config, pkgs, lib, unstable, ...}:
let
  hostblock = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts";
    hash = "sha256-INn+eVL4Ches63sttny0DnoamqbSUdKULK7VZJUoVJA=";
  };
in
{
  nix.gc = {
    automatic = true;
    dates = "monthly";
    options = "--delete-older-than 30d";
  };

  nix.settings = {
    allowed-users = [ "dgl" ];
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.systemd-boot.configurationLimit = lib.mkDefault 15;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.cleanTmpDir = true;

  boot.kernelPackages = lib.mkDefault unstable.linuxPackages_latest;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = (pkgs.system=="x86_64-linux");
  };

  # Supposedly better for the SSD
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  # Set your time zone.
  time.timeZone = "America/Asuncion";

  networking.hostName = "localdev";
  networking.hostFiles = [ hostblock ];

  networking = {
    useDHCP = false;
    useNetworkd = true;
    networkmanager.enable = false;
  };

  systemd.network.networks = let
    networkConfig = {
      DHCP = "yes";
      DNSSEC = "yes";
      DNSOverTLS = "yes";
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
  };

  # Wait for any interface to become available, not for all
  systemd.services."systemd-networkd-wait-online".serviceConfig.ExecStart = [
    "" "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --any"
  ];

  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTRS{idVendor}=="2a70", ATTRS{idProduct}=="9024", NAME="usb0"
  '';

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    videoDrivers = [ "amdgpu" ];
    windowManager.dwm.enable = true;
    libinput.enable = true;
    layout = "us";
    xkbVariant = "intl";
  };
  services.picom = {
    enable = true;
    backend = "glx";
    vSync = true;
  };

  # Enable sound.
  sound.enable = lib.mkDefault true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Virtualisation
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      dates = "weekly";
      flags = [ "--all" "--volumes" ];
    };
  };
  virtualisation.spiceUSBRedirection.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dgl = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "lp" "docker" "dialout" "adbusers"]; # Enable ‘sudo’ for the user.
    shell = pkgs.mksh;
  };

  environment.variables = {
      EDITOR = "vim";
  };

  programs.adb.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:
  services.zerotierone.enable = true;
  services.printing = {
    enable = true;
    drivers = [ pkgs.epson-escpr ];
  };

  services.openssh.enable = true;
  services.fstrim.enable = true;
  services.acpid.enable = true;
  services.fwupd.enable = true;

  # Open ports in the firewall.           # syncthing
  networking.firewall.allowedTCPPorts = [ 22000            ];
  networking.firewall.allowedUDPPorts = [ 22000 21027 8888 ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;
}

