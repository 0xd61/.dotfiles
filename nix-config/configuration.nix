
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  hostblock = pkgs.fetchurl {
    url = "https://github.com/StevenBlack/hosts/blob/4dad78108e4e9e752f625433522eeb47254379c5/alternates/fakenews-porn-social/hosts?raw=true";
    sha256 = "1n18hiizaq1ly6sandan4rv93mwbx0ssvv6685v2npv1c37z333x";
  };

in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <nix-ld/modules/nix-ld.nix>
    ];

  nix.autoOptimiseStore = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Lower GRUB resolution for faster rendering
  boot.loader.grub.gfxmodeEfi = "1024x768";

  boot.loader.grub = {
    enable = true;
    version = 2;
    efiSupport = true;
    enableCryptodisk = true;
    device = "nodev";
  };

  boot.initrd.luks.devices = {
    crypted = {
      device = "/dev/disk/by-uuid/45dce0a7-ac47-42ce-b99e-3d4d2c153731";
      preLVM = true;
    };
  };

  boot.cleanTmpDir = true;

  boot.kernelParams = [ "acpi_enforce_resources=lax" ];
  boot.initrd.kernelModules = [ "amdgpu" "nct6775" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  hardware.opengl = {
    driSupport = true;
    driSupport32Bit = true;
    enable = true;
    extraPackages = with pkgs; [
      rocm-opencl-icd
      rocm-opencl-runtime
    ];
  };

  # Supposedly better for the SSD
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  networking.hostName = "localdev";
  networking.hostFiles = [ hostblock ];

  # Set your time zone.
  time.timeZone = "UTC";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp6s0.useDHCP = true;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
  networking.networkmanager.enable = false;

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
    windowManager.dwm.enable = true;
    # displayManager.startx.enable = false; # only for debugging
    libinput.enable = true;
    layout = "us";
    xkbVariant = "intl";
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Virtualisation
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      dates = "weekly";
      flags = [ "--all" "--volumes" ];
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dgl = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "lp" "docker"]; # Enable ‘sudo’ for the user.
    shell = pkgs.mksh;
  };

  nixpkgs.overlays = with pkgs; [
    (self: super: {
      #webkitgtk = super.webkitgtk.overrideAttrs (oldAttrs: rec {
      #  propagatedBuildInputs = [
      #    gtk3
      #    libsoup
      #  ];

      #  cmakeFlags = [
      #    "-DPORT=GTK"
      #    "-DUSE_LIBHYPHEN=OFF"
      #    "-DENABLE_GAMEPAD=OFF"
      #    "-DENABLE_GTKDOC=OFF"
      #    "-DENABLE_MINIBROWSER=OFF"
      #    "-DENABLE_VIDEO=OFF"
      #    "-DENABLE_WEB_AUDIO=OFF"
      #    "-DENABLE_GEOLOCATION=OFF"
      #    "-DENABLE_TOUCH_EVENTS=OFF"
      #    "-DENABLE_DRAG_SUPPORT=OFF"
      #    "-DENABLE_WAYLAND_TARGET=OFF"
      #    "-DUSE_WPE_RENDERER=ON"
      #    "-DUSE_SYSTEM_MALLOC=OFF"
      #    "-DUSE_GSTREAMER_GL=OFF"
      #    "-DUSE_SOUP2=ON"
      #  ];
      #  });
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
            url = "https://dwm.suckless.org/patches/fancybar/dwm-fancybar-6.2.diff";
            sha256 = "1z0zx7rd9k971niy58yznzq5hb0qsxbgfq4dy0nng7hw6k5cmg2k";
          })
        ];
        configFile = writeText "config.def.h" (builtins.readFile
          (super.fetchurl {
            url = "https://raw.githubusercontent.com/0xd61/.dotfiles/master/suckless.conf.d/dwm-6.2.config.def.h";
            sha256 = "02p9qhw5vxvkimfxi1vgpgq5s0mk6agxbrpkbssljiwxsxa7qbqb";
          })
        );
        postPatch = oldAttrs.postPatch or "" + "\necho 'Using own config file...'\n cp ${configFile} config.def.h";
        });
      st = super.st.overrideAttrs (oldAttrs: rec {
        patches = [
          (super.fetchpatch {
            url = "https://st.suckless.org/patches/scrollback/st-scrollback-0.8.4.diff";
            sha256 = "0valvkbsf2qbai8551id6jc0szn61303f3l6r8wfjmjnn4054r3c";
          })
        ];
        configFile = writeText "config.def.h" (builtins.readFile
          (super.fetchurl {
            url = "https://raw.githubusercontent.com/0xd61/.dotfiles/master/suckless.conf.d/stterm-0.8.4.config.def.h";
            sha256 = "0r67y0nkdajiqsb3fr05x6dcpfzzyvn2i53g5rg7y0hx8b3d2mjd";
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
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    st
    dmenu
    dwm
    surf
    jq
    zip
    unzip
    xz
    qemu
    pavucontrol
    zerotierone
    firmwareLinuxNonfree
    htop
    acpi
  ];

  environment.variables = {
      EDITOR = "vim";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  #nix.sandboxPaths = [ "/var/cache/ccache" ];
  #programs.ccache = {
  #  enable = true;
  #  cacheDir = "/var/cache/ccache";
  #  packageNames = [
  #    "zerotierone"
  #  ];
  #};

  # List services that you want to enable:
  services.zerotierone.enable = true;
  services.printing = {
    enable = true;
    drivers = [ pkgs.epson-escpr ];
  };
  xdg.portal.enable = true; # needed by flatpak
  # services.openssh.enable = true;
  services.fstrim.enable = true;
  services.acpid.enable = true;
  services.fwupd.enable = true;


  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22000 ];
  networking.firewall.allowedUDPPorts = [ 22000 21027 8888 ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}

