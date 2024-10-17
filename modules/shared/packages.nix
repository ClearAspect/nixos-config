{pkgs}:
with pkgs; [
  # General packages for development and system management
  bat
  btop
  coreutils
  fastfetch
  fish
  kitty
  git-credential-manager
  lazygit
  lsd
  neovim
  oh-my-posh
  openssh
  killall
  yazi
  wget
  zip
  zoxide
  # zsh-autosuggestions
  # zsh-syntax-highlighting

  # Fonts
  cozette

  lua
  python3
  # llvmPackages_latest.llvm
  cargo
  cmake
  jdk
  maven
  zigpkgs.master

  # Media-related packages
  font-awesome

  # Node.js development tools
  nodePackages.npm # globally install npm
  nodePackages.prettier
  nodejs

  # Text and terminal utilities
  pass
  coreutils
  btop
  fzf
  killall
  ripgrep
  tree
  tree-sitter
  tmux
  unrar
  unzip
  wget
  zip

  # Formatter
  alejandra
]
