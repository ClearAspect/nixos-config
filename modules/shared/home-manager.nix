{
  config,
  pkgs,
  lib,
  ...
}: let
  name = "ClearAspect";
  user = "roanm";
  email = "roanmason@live.ca";
in {
  # Shared shell configuration

  fish = {
    enable = true;
    shellAliases = {
      ls = "lsd --color=auto";
      grep = "grep --color=auto";
      vi = "nvim";
      vim = "nvim";
    };
    plugins = [
      {
        name = "nix-env";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
          sha256 = "sha256-RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
        };
      }
      # {
      #   name = "catppuccin";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "catppuccin";
      #     repo = "fish";
      #     rev = "cc8e4d8fffbdaab07b3979131030b234596f18da";
      #     sha256 = "sha256-udiU2TOh0lYL7K7ylbt+BGlSDgCjMpy75vQ98C1kFcc=";
      #   };
      # }
    ];
  };

  zsh = {
    enable = false;
    autocd = false;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    completionInit = "
  if type brew &>/dev/null
  then
  fpath+=\"$(brew --prefix)/share/zsh/site-functions\"
  autoload -Uz compinit
  compinit
  fi

  zstyle ':completion:*' completer _list _expand _complete _ignored _correct _approximate
  zstyle ':completion:*' format '%F{black}-- %d --%f'
  zstyle ':completion:*' group-name ''
  zstyle ':completion:*' list-colors ''
  zstyle ':completion:*' menu select=2
  zstyle :compinstall filename '/home/roanm/.zshrc'

  autoload -Uz compinit
  compinit
  ";
    initExtraFirst = ''
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
      fi

      # Define variables for directories
      export PATH=$HOME/.pnpm-packages/bin:$HOME/.pnpm-packages:$PATH
      export PATH=$HOME/.npm-packages/bin:$HOME/bin:$PATH
      export PATH=$HOME/.local/share/bin:$PATH

      # Remove history data we don't want to see
      export HISTIGNORE="pwd:ls:cd"

    '';
  };

  fzf.enable = true;

  oh-my-posh = {
    enable = true;
    settings = builtins.fromJSON (builtins.unsafeDiscardStringContext (builtins.readFile ./config/oh-my-posh/omp.json));
  };

  bat = {
    enable = true;
    themes = {
      Catppuccin_Mocha = {
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "bat";
          rev = "d3feec47b16a8e99eabb34cdfbaa115541d374fc";
          sha256 = "sha256-s0CHTihXlBMCKmbBBb8dUhfgOOQu9PBCQ+uviy7o47w=";
        };
        file = "themes/Catppuccin Mocha.tmTheme";
      };
    };
  };

  git = {
    enable = true;
    # ignores = ["*.swp"];
    userName = name;
    userEmail = email;
    lfs = {
      enable = true;
    };
    extraConfig = {
      init.defaultBranch = "master";
      core = {
        editor = "nvim";
        # autocrlf = "input";
      };
      pull.rebase = true;
      rebase.autoStash = true;
    };
  };

  # ssh = {
  #   enable = true;
  #   includes = [
  #     (
  #       lib.mkIf pkgs.stdenv.hostPlatform.isLinux
  #       "/home/${user}/.ssh/config_external"
  #     )
  #     (
  #       lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
  #       "/Users/${user}/.ssh/config_external"
  #     )
  #   ];
  # };

  tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      catppuccin
      {
        plugin = resurrect; # Used by tmux-continuum

        # Use XDG data directory
        # https://github.com/tmux-plugins/tmux-resurrect/issues/348
        extraConfig = ''
          set -g @resurrect-dir '$HOME/.cache/tmux/resurrect'
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-pane-contents-area 'visible'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '5' # minutes
        '';
      }
    ];
    prefix = "C-a";
    escapeTime = 0;
    historyLimit = 50000;
    extraConfig = "
		unbind r
		bind r source-file ~/.tmux.conf; display-message \"Config reloaded\"


		set -g base-index 1              # start indexing windows at 1 instead of 0
		set -g escape-time 0             # zero-out escape time delay
		set -g renumber-windows on       # renumber all windows when any window is closed
		set -g set-clipboard on          # use system clipboard
		set -g status-position top
		set -g default-terminal \"$TERM\"
		setw -g mode-keys vi
		set -g mouse on

		unbind %
		bind | split-window -h
		unbind '\"'
		bind - split-window -v

		bind -r j resize-pane -D 5
		bind -r k resize-pane -U 5
		bind -r h resize-pane -L 5
		bind -r l resize-pane -R 5
		bind -r m resize-pane -Z

		bind-key -T copy-mode-vi v send-keys -X begin-selection
		bind-key -T copy-mode-vi y send-keys -X copy-selection
		unbind -T copy-mode-vi MouseDragEnd1Pane



		set -g @plugin 'catppuccin/tmux#latest'

		set -g @resurrect-capture-pane-contents 'on'
		set -g @continuum-restore 'on'

		set -g @catppuccin_flavour 'mocha'
		set -g @catppuccin_window_number_position 'right'
		set -g @catppuccin_window_left_separator ' '
		set -g @catppuccin_window_right_separator ''
		set -g @catppuccin_window_middle_separator ' █'
		";
  };
}
