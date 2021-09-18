# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

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

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # acpi_rev_override=1 iommu=on drm.vblankoffdelay=1 enable_fbc=1 enable_psr=1 disable_power_well=0 pci=noaer pcie_aspm=force nmi_watchdog=0 intel_pstate=no_hwp acpi.debug_level=0x2 acpi.debug_layer=0xFFFFFFFF
  boot.kernelParams = [ "acpi_rev_override=1" "enable_psr=1" "disable_power_well=0" "acpi.debug_level=0x2" "acpi.debug_layer=0xFFFFFFFF" "pci=noaer" ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 0;
    "kernel.sysrq" = 1;
    "kernel.nmi_watchdog" = 0;
    "vm.laptop_mode" = 5;
    "vm.dirty_writeback_centisecs" = 2000;
  };

  boot.extraModprobeConfig = "
    options snd_hda_intel power_save=1 power_save_controller=y
    options i915 enable_psr=2 enable_rc6=7 enable_fbc=1 semaphores=1 lvds_downclock=1 enable_guc_loading=1 enable_guc_submission=1
    options iwldvm force_cam=0
  ";

  systemd.tmpfiles.rules = [
    "w /sys/devices/system/cpu/cpufreq/policy?/energy_performance_preference - - - - balance_power"
  ];

  services.udev = {
      extraRules = ''
        # disable bluetooth
        SUBSYSTEM=="rfkill", ATTR{type}=="bluetooth", ATTR{state}="0"

        # Powersave wifi
        ACTION=="add", SUBSYSTEM=="net", KERNEL=="wl*", RUN+="${pkgs.iw}/bin/iw dev $name set power_save on"

        # PCI pm
        SUBSYSTEM=="pci", ATTR{power/control}="auto"

        # USB autosuspend
        # blacklist for usb autosuspend
        ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0416", ATTR{idProduct}=="0123", GOTO="power_usb_rules_end"
        ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c52b", ATTR{power/autosuspend}="20"

        ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
        LABEL="power_usb_rules_end"

        # Sata
        ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="med_power_with_dipm"

        # CPU frequency
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", RUN+="${pkgs.bash}/bin/sh -c 'echo 5  > /sys/devices/system/cpu/intel_pstate/min_perf_pct'"
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", RUN+="${pkgs.bash}/bin/sh -c 'echo 80  > /sys/devices/system/cpu/intel_pstate/max_perf_pct'"
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", RUN+="${pkgs.bash}/bin/sh -c 'echo 1   > /sys/devices/system/cpu/intel_pstate/no_turbo'"
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", RUN+="${pkgs.bash}/bin/sh -c 'echo balance_power > /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference'"
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", RUN+="${pkgs.bash}/bin/sh -c 'echo balance_power > /sys/devices/system/cpu/cpu1/cpufreq/energy_performance_preference'"
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", RUN+="${pkgs.bash}/bin/sh -c 'echo balance_power > /sys/devices/system/cpu/cpu2/cpufreq/energy_performance_preference'"
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", RUN+="${pkgs.bash}/bin/sh -c 'echo balance_power > /sys/devices/system/cpu/cpu3/cpufreq/energy_performance_preference'"
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", RUN+="${pkgs.bash}/bin/sh -c 'echo balance_power > /sys/devices/system/cpu/cpu4/cpufreq/energy_performance_preference'"
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", RUN+="${pkgs.bash}/bin/sh -c 'echo balance_power > /sys/devices/system/cpu/cpu5/cpufreq/energy_performance_preference'"
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", RUN+="${pkgs.bash}/bin/sh -c 'echo balance_power > /sys/devices/system/cpu/cpu6/cpufreq/energy_performance_preference'"
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", RUN+="${pkgs.bash}/bin/sh -c 'echo balance_power > /sys/devices/system/cpu/cpu7/cpufreq/energy_performance_preference'"

        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", RUN+="${pkgs.bash}/bin/sh -c 'echo 5  > /sys/devices/system/cpu/intel_pstate/min_perf_pct'"
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", RUN+="${pkgs.bash}/bin/sh -c 'echo 90  > /sys/devices/system/cpu/intel_pstate/max_perf_pct'"
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", RUN+="${pkgs.bash}/bin/sh -c 'echo 1   > /sys/devices/system/cpu/intel_pstate/no_turbo'"
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", RUN+="${pkgs.bash}/bin/sh -c 'echo balance_performance > /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference'"
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", RUN+="${pkgs.bash}/bin/sh -c 'echo balance_performance > /sys/devices/system/cpu/cpu1/cpufreq/energy_performance_preference'"
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", RUN+="${pkgs.bash}/bin/sh -c 'echo balance_performance > /sys/devices/system/cpu/cpu2/cpufreq/energy_performance_preference'"
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", RUN+="${pkgs.bash}/bin/sh -c 'echo balance_performance > /sys/devices/system/cpu/cpu3/cpufreq/energy_performance_preference'"
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", RUN+="${pkgs.bash}/bin/sh -c 'echo balance_performance > /sys/devices/system/cpu/cpu4/cpufreq/energy_performance_preference'"
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", RUN+="${pkgs.bash}/bin/sh -c 'echo balance_performance > /sys/devices/system/cpu/cpu5/cpufreq/energy_performance_preference'"
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", RUN+="${pkgs.bash}/bin/sh -c 'echo balance_performance > /sys/devices/system/cpu/cpu6/cpufreq/energy_performance_preference'"
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", RUN+="${pkgs.bash}/bin/sh -c 'echo balance_performance > /sys/devices/system/cpu/cpu7/cpufreq/energy_performance_preference'"
      '';
  };

  # Supposedly better for the SSD
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  # needed for the nvidia
  nixpkgs.config.allowUnfree = true;
  nix.autoOptimiseStore = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  hardware.cpu.intel.updateMicrocode = true;

  networking.hostName = "localdev";
  networking.wireless.enable = true;
  networking.wireless.userControlled.enable = true;
  networking.wireless.networks = {
    "samuu tech s.r.l" = {
      pskRaw = "6c6eb28ce0ef7f12245c4b12fe39ad72a3a9937367b3bfa3c2293b87c70a7035";
    };
    "405 Wi-Fi not allowed" = {
      pskRaw = "06da83698df67a3061dab1a5b5822932534035013b7d63b0fc6786131fbffafa";
      priority = 60;
    };
    "404 Wi-Fi not found" = {
      pskRaw = "83664cc2285d791b21fe990215f1c77737ef58c20c1f6414eff3b91a0540abe2";
      priority = 60;
    };
    "Fb590_52_E" = {
      pskRaw = "1177aa2ef3bc66732e3afa0297eb1dc2bf4858ac7914313b3a557b5036d679b5";
    };
    "Segensquelle" = {
      pskRaw = "70b81ca01ffdadfcec82d3d6b5d8cee79dbea292d570cf4ae62c0d424f2a2880";
    };
  };

  # Set your time zone.
  time.timeZone = "UTC";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  #networking.interfaces.enp62s0u1u1.useDHCP = true;
  networking.interfaces.wlp2s0.useDHCP = true;
  networking.wireless.interfaces = [ "wlp2s0"];
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
  networking.networkmanager.enable = false;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    windowManager.dwm.enable = true;
    libinput.enable = true;
    videoDrivers = [ "nvidia" ];
    layout = "de";
    #xkbVariant = "intl";
  };

  # I belive this is necessary for steam and wine
  hardware.opengl.driSupport32Bit = true;
  hardware.nvidia.prime = {
    offload.enable = true;
    intelBusId = "PCI:00:02:0";
    nvidiaBusId = "PCI:01:00:0";
  };
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.powerManagement.finegrained = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Virtualisation
  virtualisation.docker.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dgl = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "lp" "docker"]; # Enable ‘sudo’ for the user.
    shell = pkgs.mksh;
  };

  nixpkgs.overlays = with pkgs; [
    (self: super: {
      dwm = super.dwm.overrideAttrs (oldAttrs: rec {
        patches = [
          (super.fetchpatch {
            url = "https://dwm.suckless.org/patches/fancybar/dwm-fancybar-6.2.diff";
            sha256 = "0bf55553p848g82jrmdahnavm9al6fzmd2xi1dgacxlwbw8j1xpz";
          })
        ];
        configFile = writeText "config.def.h" (builtins.readFile
          (super.fetchpatch {
            url = "https://raw.githubusercontent.com/0xd61/.dotfiles/master/suckless.conf.d/dwm-6.2.config.def.h";
            sha256 = "1wc5wqdj9g9pz4yywgw0k5aa6nkc07n15zmqb1i92s75phbyca52";
          })
        );
        postPatch = oldAttrs.postPatch or "" + "\necho 'Using own config file...'\n cp ${configFile} config.def.h";
        });
      st = super.st.overrideAttrs (oldAttrs: rec {
        patches = [
          (super.fetchpatch {
            url = "https://st.suckless.org/patches/scrollback/st-scrollback-0.8.4.diff";
            sha256 = "0i0fav13sxnsydpllny26139gnzai66222502cplh18iy5fir3j1";
          })
        ];
        configFile = writeText "config.def.h" (builtins.readFile
          (super.fetchpatch {
            url = "https://raw.githubusercontent.com/0xd61/.dotfiles/master/suckless.conf.d/stterm-0.8.4.config.def.h";
            sha256 = "0r67y0nkdajiqsb3fr05x6dcpfzzyvn2i53g5rg7y0hx8b3d2mjd";
          })
        );
        postPatch = oldAttrs.postPatch or "" + "\necho 'Using own config file...'\n cp ${configFile} config.def.h";
      });
    })
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    #steam = pkgs.steam.override {
    #  nativeOnly = true;
    #};
  };

  programs.steam.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    firefox
    git
    st
    dmenu
    dwm
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
    intel-gpu-tools
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

  # List services that you want to enable:
  services.zerotierone.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  services.acpid.enable = true;
  services.undervolt = {
    enable = false; # not working with current bios
    verbose = true;
    coreOffset = -125;
    gpuOffset = -75;
    analogioOffset = 0;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
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

