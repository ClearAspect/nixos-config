{
  config,
  pkgs,
  lib,
  ...
}: let
  user = "roanm";
  xdg_configHome = "/home/${user}/.config";
  shared-programs = import ../shared/home-manager.nix {inherit config pkgs lib;};
  shared-files = import ../shared/files.nix {inherit config pkgs;};
in {
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${user}";
    homeDirectory = "/home/${user}";
    packages = pkgs.callPackage ./packages.nix {};
    file = shared-files // import ./files.nix {inherit user;};
    stateVersion = "21.05";
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    xwayland.enable = true;

    systemd.enable = true;

    settings = {
      monitor = [
        "DP-1,3840x2160@144,0x0,1"
        "HDMI-A-1,3840x2160@60,-3840x0,1"
        "Unknown-1, disable"
      ];

      "$mainMod" = "SUPER";
      "$terminal" = "kitty";
      "$browser" = "firefox";

      bind = [
        "$mainMod, T, exec, $terminal"
        "$mainMod, F, exec, $browser"
        "$mainMod, C, killactive"

        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 10, workspace, 10"
      ];
      # extraConfig = ''
      #   env = XCURSOR_SIZE,24
      #   env = HYPRCURSOR_SIZE,24
      #   env = LIBVA_DRIVER_NAME,nvidia
      #   env = XDG_SESSION_TYPE,wayland
      #   env = GBM_BACKEND,nvidia-drm
      #   env = __GLX_VENDOR_LIBRARY_NAME,nvida
      #   env = __GL_GSYNC_ALLOWED
      # '';
    };
  };

  # Use a dark theme
  gtk = {
    enable = true;
    cursorTheme = {
      name = "Apple Cursor";
      package = pkgs.apple-cursor;
    };
    iconTheme = {
      name = "WhiteSur Icons";
      package = pkgs.whitesur-icon-theme;
    };
    theme = {
      name = "WhiteSur Theme";
      package = pkgs.whitesur-gtk-theme;
    };
  };

  # Screen lock
  services = {
    # Auto mount devices
    # udiskie.enable = true;

    # polybar = {
    #   enable = true;
    #   config = polybar-config;
    #   extraConfig = polybar-bars + polybar-colors + polybar-modules + polybar-user_modules;
    #   package = pkgs.polybarFull;
    #   script = "polybar main &";
    # };

    # dunst = {
    #   enable = true;
    #   package = pkgs.dunst;
    #   settings = {
    #     global = {
    #       monitor = 0;
    #       follow = "mouse";
    #       border = 0;
    #       height = 400;
    #       width = 320;
    #       offset = "33x65";
    #       indicate_hidden = "yes";
    #       shrink = "no";
    #       separator_height = 0;
    #       padding = 32;
    #       horizontal_padding = 32;
    #       frame_width = 0;
    #       sort = "no";
    #       idle_threshold = 120;
    #       font = "Noto Sans";
    #       line_height = 4;
    #       markup = "full";
    #       format = "<b>%s</b>\n%b";
    #       alignment = "left";
    #       transparency = 10;
    #       show_age_threshold = 60;
    #       word_wrap = "yes";
    #       ignore_newline = "no";
    #       stack_duplicates = false;
    #       hide_duplicate_count = "yes";
    #       show_indicators = "no";
    #       icon_position = "left";
    #       icon_theme = "Adwaita-dark";
    #       sticky_history = "yes";
    #       history_length = 20;
    #       history = "ctrl+grave";
    #       browser = "google-chrome-stable";
    #       always_run_script = true;
    #       title = "Dunst";
    #       class = "Dunst";
    #       max_icon_size = 64;
    #     };
    #   };
    # };
  };

  programs = shared-programs // {};
}
