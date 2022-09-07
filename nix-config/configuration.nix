
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  hostblock = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts";
    hash = "sha256-INn+eVL4Ches63sttny0DnoamqbSUdKULK7VZJUoVJA=";
  };

  unstable = import (fetchTarball https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz) { };
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  nixpkgs.config.allowUnfree = true;

  nix.autoOptimiseStore = true;
  nix.gc = {
    automatic = true;
    dates = "monthly";
    options = "--delete-older-than 30d";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 15;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.cleanTmpDir = true;

  boot.initrd.kernelModules = [ "amdgpu" "nct6775" ];
  boot.kernelPackages = unstable.linuxPackages_xanmod_latest;

  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
  };

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
      DNS = [ "1.1.1.1" "1.0.0.1" ];
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

  nixpkgs.overlays = with pkgs; [
    (self: super: {
        dwl = super.dwl.overrideAttrs (oldAttrs: rec {
          enable-xwayland = true;
          configFile = writeText "config.def.h" (builtins.readFile
            (super.fetchurl {
              url = "https://raw.githubusercontent.com/0xd61/.dotfiles/master/suckless.conf.d/dwl-0.2.2.config.def.h";
              hash = "sha256-WopZLgeXpBjdyrMcUlwe/GzcVZP+k8jssHAC7cpaypM=";
            })
          );
          postPatch = oldAttrs.postPatch or "" + "\necho 'Using own config file...'\n cp ${configFile} config.def.h";
      });
      dmenu = super.dmenu.overrideAttrs (oldAttrs: rec {
        patches = [
          (super.fetchpatch {
            url = "https://raw.githubusercontent.com/0xd61/.dotfiles/master/suckless.conf.d/dmenu-5.0-backspace-delete-word.diff";
            sha256 = "0abqi59zp1ynmzmf0k524n4s589cnli07kxi2y9ngkyzhvbjav7k";
          })
        ];
        });
        dwm = super.dwm.overrideAttrs (oldAttrs: rec {
          patches = [
            (super.fetchpatch {
              url = "https://dwm.suckless.org/patches/fancybar/dwm-fancybar-20220527-d3f93c7.diff";
              sha256 = "twTkfKjOMGZCQdxHK0vXEcgnEU3CWg/7lrA3EftEAXc=";
            })
          ];
          configFile = writeText "config.def.h" (builtins.readFile
            (super.fetchurl {
              url = "https://raw.githubusercontent.com/0xd61/.dotfiles/master/suckless.conf.d/dwm-6.3.config.def.h";
              hash = "sha256-Umi0wlGqUxfHPEQffjiQu2yk0IWMiePXXupmcKds2XU=";
            })
          );
          postPatch = oldAttrs.postPatch or "" + "\necho 'Using own config file...'\n cp ${configFile} config.def.h";
        });
        st = super.st.overrideAttrs (oldAttrs: rec {
          patches = [
            (super.fetchpatch {
              url = "https://st.suckless.org/patches/scrollback/st-scrollback-0.8.5.diff";
              sha256 = "ZZAbrWyIaYRtw+nqvXKw8eXRWf0beGNJgoupRKsr2lc=";
            })
          ];
          configFile = writeText "config.def.h" (builtins.readFile
            (super.fetchurl {
              url = "https://raw.githubusercontent.com/0xd61/.dotfiles/master/suckless.conf.d/stterm-0.8.5.config.def.h";
              sha256 = "DLQUqfa8FDsff0m4ioZCKO4hVJ0vFKSLhvXmxOxvDf8=";
            })
          );
          postPatch = oldAttrs.postPatch or "" + "\necho 'Using own config file...'\n cp ${configFile} config.def.h";
        });


      surf = super.surf.overrideAttrs (oldAttrs: rec {
        patches = [
          (super.fetchpatch {
            url = "https://surf.suckless.org/patches/popup-on-gesture/surf-popup-2.0.diff";
            sha256 = "0zqf4cfzz5l0gqayj8xba6xqzzyc2ifqjclw0k7v4b4him9y3l3m";
          })
          (super.fetchpatch {
            url = "https://surf.suckless.org/patches/clipboard-instead-of-primary/surf-clipboard-20200112-a6a8878.diff";
            sha256 = "1rnqis9s9fqa4nj2c6mjzjxqcnlvcjmhmd39qf45z6lv77byb7rh";
          })
          (super.fetchpatch {
            url = "https://surf.suckless.org/patches/playexternal/surf-playexternal-20190724-b814567.diff";
            sha256 = "19r6mgsi47w0gy9hl4knkl8z65ghl42p9rb4pps0681wzn3hk2cz";
          })
          (super.fetchpatch {
            url = "https://raw.githubusercontent.com/0xd61/.dotfiles/master/suckless.conf.d/surf-2.1-history.diff";
            sha256 = "07fgh6msd3za79p5yf1g52kchvg4cfdxbrnzymr1ljq0wkcni8h5";
          })
          (super.fetchpatch {
            url = "https://raw.githubusercontent.com/0xd61/.dotfiles/master/suckless.conf.d/surf-2.1-spacesearch.diff";
            sha256 = "0mwwkqyqchq6n9r3x1qdpm4mvzcba257waf61h7hpjcqi41ql94i";
          })
          (super.fetchpatch {
            url = "https://raw.githubusercontent.com/0xd61/.dotfiles/master/suckless.conf.d/surf-2.1-hardware-acceleration.diff";
            sha256 = "1vgs7qii2yccvfghjd6phf3j12vslxwzr5sw2k8sfll2fvqxilq0";
          })
        ];
        configFile = writeText "config.def.h" (builtins.readFile
          (super.fetchurl {
            url = "https://raw.githubusercontent.com/0xd61/.dotfiles/master/suckless.conf.d/surf-2.1.config.def.h";
            sha256 = "0dk5kzdyg4lk64yg3d6311lmywzcf4z62h0blssyq3ymrg173sll";
          })
        );
        postPatch = oldAttrs.postPatch or "" + "\necho 'Using own config file...'\n cp ${configFile} config.def.h";
      });
    })
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    st
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
    jq
    zip
    unzip
    xz
    qemu
    zerotierone
    htop
    acpi
  ];

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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}

