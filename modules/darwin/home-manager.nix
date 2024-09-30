{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}: let
  user = "roanm";
  # Define the content of your file as a derivation
  sharedFiles = import ../shared/files.nix {inherit config pkgs;};
  additionalFiles = import ./files.nix {inherit user config pkgs;};
in {
  imports = [
    ./dock
  ];

  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix {};
    # onActivation.cleanup = "uninstall";

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    # If you have previously added these apps to your Mac App Store profile (but not installed them on this system),
    # you may receive an error message "Redownload Unavailable with This Apple ID".
    # This message is safe to ignore. (https://github.com/dustinlyons/nixos-config/issues/83)
    # masApps = {
    #   "1password" = 1333542190;
    #   "wireguard" = 1451685025;
    # };
  };

  security.pam.enableSudoTouchIdAuth = true;

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = {
      pkgs,
      config,
      lib,
      ...
    }: {
      home = {
        enableNixpkgsReleaseCheck = false;
        packages = pkgs.callPackage ./packages.nix {};
        file = lib.mkMerge [
          sharedFiles
          additionalFiles
        ];
        stateVersion = "23.11";

        sessionVariables = {
          EDITOR = "nvim";
          BAT_THEME = "Catppuccin_Mocha";
        };
        sessionPath = [
          "${config.home.homeDirectory}/.cargo/bin"
          "${config.home.homeDirectory}/.local/bin"
          "${config.home.homeDirectory}/.local/share/nvim/mason/bin"
        ];

        shellAliases = {
          ls = "lsd --color=auto";
          grep = "grep --color=auto";
          vi = "nvim";
          vim = "nvim";
        };
      };
      programs = {} // import ../shared/home-manager.nix {inherit config pkgs lib;};

      # Marked broken Oct 20, 2022 check later to remove this
      # https://github.com/nix-community/home-manager/issues/3344
      manual.manpages.enable = false;
    };
  };

  # Fully declarative dock using the latest from Nix Store
  local.dock.enable = true;
  local.dock.entries = [
    {path = "/System/Applications/Launchpad.app/";}
    {path = "/Applications/Safari.app/";}
    {path = "/System/Applications/Messages.app/";}
    {path = "/System/Applications/Mail.app/";}
    {path = "/System/Applications/Photos.app/";}
    {path = "/System/Applications/Facetime.app/";}
    {path = "/System/Applications/Calendar.app/";}
    {path = "/System/Applications/Contacts.app/";}
    {path = "/System/Applications/Reminders.app/";}
    {path = "/System/Applications/Notes.app/";}
    {path = "/System/Applications/Music.app/";}
    {path = "/System/Applications/App Store.app/";}
    {path = "/System/Applications/System Settings.app/";}
    {path = "/Applications/Firefox.app/";}
    {path = "/Applications/Discord.app/";}
    {path = "/Applications/Kitty.app/";}
  ];
}
