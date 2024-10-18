{
  config,
  lib,
  inputs,
  pkgs,
  libs,
  ...
}: let
  user = "roanm";
  keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOk8iAnIaa1deoc7jw8YACPNVka1ZFJxhnU4G74TmS+p"];
in {
  imports = [
    ../../modules/nixos/disk-config.nix
    ../../modules/shared
  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      # systemd-boot = {
      #   enable = true;
      #   configurationLimit = 4;
      # };
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        configurationLimit = 4;
      };
      efi.canTouchEfiVariables = true;
    };
    initrd.availableKernelModules = [
      "nvidia"
      "nvidia_modeset"
      "nvidia_uvm"
      "nvidia_drm"
      "xhci_pci"
      "ahci"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    initrd.kernelModules = [
      "nvidia"
      "nvidia_modeset"
      "nvidia_uvm"
      "nvidia_drm"
    ];

    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = ["uinput"];
    kernelParams = [
      "nvidia-drm.modeset=1"
      "nvidia-drm.fbdev=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia.NVreg_EnableGpuFirmware=0"
      "video=simpledrm:off"
      "module_blacklist=simpledrm"
    ];
  };

  # Setup Nvidia Drivers
  hardware.graphics.enable = true; # OpenGL
  services = {
    udev.packages = [config.boot.kernelPackages.nvidiaPackages.stable];
    xserver = {
      enable = true;
      displayManager.gdm = {
        enable = true;
      };

      videoDrivers = ["nvidia"];

      # Uncomment for Nvidia GPU
      # This helps fix tearing of windows for Nvidia cards
      # screenSection = ''
      #   Option       "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
      #   Option       "AllowIndirectGLXProtocol" "off"
      #   Option       "TripleBuffer" "on"
      # '';

      # Turn Caps Lock into Ctrl
      xkb.layout = "us";
      # xkbOptions = "ctrl:nocaps";
    };
  };
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    # forceFullCompositionPipeline = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    # prime = {
    #   # sync.enable = true;
    #   nvidiaBusId = "PCI:1:0:0";
    # };
  };

  # Set your time zone.
  time.timeZone = "Canada/Eastern";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
    hostName = "nixos"; # Define your hostname.
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
    # useDHCP = lib.mkDefault true;
    useDHCP = lib.mkDefault true;
    # interfaces."%INTERFACE%".useDHCP = true;
  };

  # Turn on flag for proprietary software
  nix = {
    nixPath = ["nixos-config=/home/${user}/.local/share/src/nixos-config:/etc/nixos"];
    settings = {
      allowed-users = ["${user}"];
      trusted-users = ["@admin" "${user}"];
      substituters = ["https://nix-community.cachix.org" "https://cache.nixos.org"];
      trusted-public-keys = ["cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="];
    };

    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Manages keys and such
  programs = {
    gnupg.agent.enable = true;

    # Needed for anything GTK related
    dconf.enable = true;

    # My shell
    fish.enable = true;

    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
  };

  services = {
    # Better support for general peripherals
    libinput.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # Let's be able to SSH into this machine
    openssh.enable = true;

    # Sync state between machines
    # syncthing = {
    #   enable = true;
    #   openDefaultPorts = true;
    #   dataDir = "/home/${user}/.local/share/syncthing";
    #   configDir = "/home/${user}/.config/syncthing";
    #   user = "${user}";
    #   group = "users";
    #   guiAddress = "127.0.0.1:8384";
    #   overrideFolders = true;
    #   overrideDevices = true;

    #   settings = {
    #     devices = {};
    #     options.globalAnnounceEnabled = false; # Only sync on LAN
    #   };
    # };

    # Enable CUPS to print documents
    printing.enable = true;
    printing.drivers = [pkgs.brlaser]; # Brother printer driver

    gvfs.enable = true; # Mount, trash, and other functionalities
    tumbler.enable = true; # Thumbnail support for images
  };

  # Audio support
  hardware = {
    pulseaudio.enable = false;
  };

  # It's me, it's you, it's everyone
  users.users = {
    ${user} = {
      home = "/home/roanm";
      createHome = true;
      isNormalUser = true;
      extraGroups = [
        "wheel" # Enable ‘sudo’ for the user.
        "docker"
      ];
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = keys;
    };

    root = {
      openssh.authorizedKeys.keys = keys;
    };
  };

  # Don't require password for users in `wheel` group for these commands
  security.sudo = {
    enable = true;
    extraRules = [
      {
        commands = [
          {
            command = "${pkgs.systemd}/bin/reboot";
            options = ["NOPASSWD"];
          }
        ];
        groups = ["wheel"];
      }
    ];
  };

  fonts.packages = with pkgs; [
    font-awesome
  ];

  environment.systemPackages = with pkgs; [
    kitty
    waybar
    hyprland
    xdg-desktop-portal-hyprland
    lshw
    vim
    coreutils
    pciutils
  ];

  system.stateVersion = "21.05"; # Don't change this
}
