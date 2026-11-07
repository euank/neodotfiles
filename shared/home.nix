# home-manager configuration for a machine without a desktop, i.e. a headless server,
# but still with my dev setup

{
  pkgs,
  lib,
  config,
  ...
}:

let
  sessionVariables = {
    EDITOR = "nvim";
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig:${pkgs.opencv4}/lib/pkgconfig:${pkgs.libX11.dev}/lib/pkgconfig:${pkgs.libXrandr.dev}/lib/pkgconfig:${pkgs.libxcb.dev}/lib/pkgconfig:${pkgs.libopus.dev}/lib/pkgconfig:${pkgs.sqlite.dev}/lib/pkgconfig:${pkgs.udev.dev}/lib/pkgconfig:${pkgs.pam}/lib/pkgconfig:${pkgs.elfutils.dev}/lib/pkgconfig:${pkgs.ncurses.dev}/lib/pkgconfig";
    NIX_DEBUG_INFO_DIRS = "/run/dwarffs";
    PROTOC = "${pkgs.protobuf}/bin/protoc";

    GLFW_SO_PATH = "${pkgs.glfw3}/lib/libglfw.so";
    OPENAL_SO_PATH = "${pkgs.openal}/lib/libopenal.so";
    DISPLAY = ":0"; # xwayland

    COWPATH = "${pkgs.cowsay}/share/cows:${pkgs.tewisay}/share/tewisay/cows";
    NIXOS_OZONE_WL = "1";
    GH_TELEMETRY = "false";
    DO_NOT_TRACK = "true";

    NIX_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.stdenv.cc.cc
      pkgs.openssl
    ];
    NIX_LD = pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
  };

  zsh-p10k-jj = pkgs.fetchFromGitHub {
    owner = "xs5871";
    repo = "p10k-jj-status";
    rev = "a98672e1cd23f1010875bf6fb376a33b1740a484";
    hash = "sha256-hTKzE7hNgKwASC4RbyCW8S9F7KaTqqyLBKtkTM7Sz/w=";
  };

in
{
  imports = [
    ./vim/vim.nix
  ];
  home.packages = with pkgs; [
    _1password-cli
    amazon-ecr-credential-helper
    asciinema
    atuin
    autorandr
    awscli2
    bandwhich
    bc
    bind
    binutils
    binutils
    bison
    borgbackup
    boringtun
    cfssl
    cntr
    colmena
    cowsay
    d-spy
    darktable
    deno
    devenv
    dua
    dumbpipe
    efibootmgr
    elfutils
    ethtool
    exiftool
    eza
    ffmpeg-full
    figlet
    file
    fish
    flamegraph
    flex
    flyctl
    font-manager
    fx-cast-bridge
    gcc
    gdb
    gh
    git-spice
    gnumake
    gnupg
    go_1_26
    gofumpt
    gopls
    gradle
    heaptrack
    htop
    hyperfine
    inotify-tools
    iotop
    iperf3
    iptables
    iputils
    iroh-ssh
    iw
    jjui
    jq
    jujutsu
    k3s
    kind
    kubernetes-helm
    (lib.hiPrio kubectl)
    lazyjj
    linear-cli
    lld
    lshw
    lsof
    maestral
    mkvtoolnix
    moreutils
    multipath-tools
    multitail
    mvn2nix
    ncurses
    ngrok
    nil
    nix-index
    nix-tree
    nixd
    nixfmt
    nixos-install-tools
    nixpkgs-fmt
    nixpkgs-review
    nmap
    nodejs
    nwg-look
    obsidian
    onetun
    openssl
    (lib.hiPrio opener-client)
    p7zip
    parted
    pass
    pavucontrol
    pciutils
    perf-tools
    pkg-config
    postgresql
    pwgen
    railway
    redis
    reptyr
    rf
    ripgrep
    ruby
    rustup
    sbsigntool
    sendme
    shotgun
    slop
    smartmontools
    sops
    sqlite
    sqlite.dev
    sshfs
    tcpdump
    tewisay
    tig
    tmux
    toilet
    tokei
    tor-browser
    tree
    treefmt
    tweag-credential-helper
    typescript-language-server
    unzip
    usbutils
    w3m
    wal-g
    wasm-pack
    wavemon
    waypipe
    wireguard-tools
    wirelesstools
    wireshark
    wlr-randr
    xan
    xclip
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
    xdg-desktop-portal-wlr
    xdg-user-dirs
    xdg-utils
    xdotool
    xeyes
    yaml2nix
    yt-dlp
    zed-editor
    zip
    zmx
    zsh-powerlevel10k

    anthropic-cli
    claude-code
    codex
    happy-coder
    herdr
    herdr-core
    ollama
    (llm.withPlugins {
      llm-anthropic = true;
      llm-gemini = true;

      llm-cmd = true;
      llm-docs = true;
      llm-fragments-github = true;
      llm-hacker-news = true;
      llm-jq = true;
      llm-tools-sqlite = true;
    })
    opencode
    pi


    # misc
    efibootmgr
    # efitools
    inotify-tools
    lld
    lshw
    usbutils
    sbsigntool
    wal-g
    mkvtoolnix
    xeyes
    gnupg
  ];

  home.sessionVariables = sessionVariables;
  systemd.user.sessionVariables = sessionVariables;

  programs.autorandr.enable = true;

  programs.atuin.enable = true;
  programs.home-manager.enable = true;

  home.activation.codexPersonalHome = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p -m 700 ${lib.escapeShellArg "${config.home.homeDirectory}/.codex-personal"}
  '';

  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    history = {
      save = 1000000;
    };
    shellAliases = {
      codex-personal = "CODEX_HOME=\"$HOME/.codex-personal\" codex -c 'cli_auth_credentials_store=\"file\"'";
      ls = "ls --color=auto";
      k = "kubectl";
      d = "zmx detach";
      a = "zmx attach";
      # no trains here
      sl = "zmx list";
    };
    initContent = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source "${../shared/zsh/p10k.zsh}"
      source ${zsh-p10k-jj}/p10k-jj-status.plugin.zsh
      source "${../shared/zsh/zshrc}"
      # Keep existing PATH entries in place; prepend only missing directories.
      for path_dir in "$HOME/.nix-profile/bin" "$HOME/bin" "$HOME/.local/bin"; do
        if [[ ":$PATH:" != *":$path_dir:"* ]]; then
          export PATH="$path_dir:$PATH"
        fi
      done
      unset path_dir
      command -v ngrok &>/dev/null && source <(ngrok completion)
    '';
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    signing.format = null;
    settings = {
      user = {
        name = "Euan Kemp";
        email = "euank@" + "euan" + "k.com";
      };
      alias = {
        co = "checkout";
        lba = "branch --sort=-committerdate --format='%(committerdate:relative)%09%(refname:short)'";
        s = "status";
      };
      merge.tool = "vimdiff";
      "mergetool \"vimdiff\"".cmd = "nvim -d $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";
    };
  };

  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;

  programs.pazi = {
    enable = true;
    enableZshIntegration = true;
  };

  xdg = {
    enable = true;

    userDirs = {
      enable = true;
      setSessionVariables = true;
      desktop = "$HOME/Desktop";
      download = "$HOME/Downloads";
      documents = "$HOME/Documents";
      templates = "$HOME/Templates";
      music = "$HOME/Music";
      videos = "$HOME/Videos";
      pictures = "$HOME/Pictures";
      publicShare = "$HOME/share/public";
    };

    mimeApps = {
      enable = true;
      associations.added = {
        "image/png" = "feh.desktop";
        "image/jpeg" = "feh.desktop";
        "application/pdf" = [ "org.gnome.Evince.desktop" ];
        "inode/directory" = [ "nemo.desktop" ];
      };

      associations.removed = {
        "inode/directory" = [ "YACReader.desktop" ];
      };

      defaultApplications = {
        "application/pdf" = lib.mkForce [ "org.gnome.Evince.desktop" ];
        "inode/directory" = lib.mkForce [ "nemo.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
        "text/html" = [ "firefox.desktop" ];
      };
    };
  };

  home.stateVersion = "20.03";
}
