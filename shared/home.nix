# home-manager configuration for a machine without a desktop, i.e. a headless server,
# but still with my dev setup

{ config, pkgs, ... }:

let
  sessionVariables = {
    EDITOR = "nvim";
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig:${pkgs.opencv4}/lib/pkgconfig:${pkgs.xorg.libX11.dev}/lib/pkgconfig:${pkgs.xorg.libXrandr.dev}/lib/pkgconfig:${pkgs.xorg.libxcb.dev}/lib/pkgconfig:${pkgs.libopus.dev}/lib/pkgconfig:${pkgs.sqlite.dev}/lib/pkgconfig:${pkgs.udev.dev}/lib/pkgconfig:${pkgs.pam}/lib/pkgconfig:${pkgs.elfutils.dev}/lib/pkgconfig:${pkgs.ncurses.dev}/lib/pkgconfig";
    NIX_DEBUG_INFO_DIRS = "/run/dwarffs";
    PROTOC = "${pkgs.protobuf}/bin/protoc";

    COWPATH = "${pkgs.cowsay}/share/cows:${pkgs.tewisay}/share/tewisay/cows";
    NIXOS_OZONE_WL = "1";
  };
in
{
  home.packages = with pkgs; [
    amazon-ecr-credential-helper
    atuin
    # ast-grep
    binutils
    borgbackup
    cfssl
    darktable
    # temporary due to nix issues
    colmena
    cntr
    iotop
    smartmontools
    cowsay
    dua
    maestral
    multitail
    eza
    ffmpeg-full
    figlet
    file
    fish
    flamegraph
    flyctl
    font-manager
    fx_cast_bridge
    heaptrack
    htop
    iptables
    iw
    jmtpfs
    jq
    jujutsu
    k3s
    krita
    (hiPrio kubectl)
    kubernetes-helm
    libreoffice
    llm
    lsof
    ngrok
    nickel
    nil
    nitrogen
    nix-index
    nix-tree
    nixfmt-rfc-style
    nixos-install-tools
    nixpkgs-fmt
    nmap
    nwg-look
    moreutils
    obsidian
    onetun
    openssl
    nixd
    postgresql
    p7zip
    pass
    pciutils
    pavucontrol
    pwgen
    redis
    ripgrep
    semgrep
    shotgun
    sqlite
    sqlite.dev
    sshfs
    tcpdump
    tewisay
    tig
    tmate
    tmux
    toilet
    tree
    unzip
    wasm-pack
    wavemon
    wirelesstools
    wireguard-tools
    wireshark
    yt-dlp
    xdg-utils
    xan
    slop
    zed-editor
    zip
    zsh-powerlevel10k
    manga-ocr

    sway-contrib.grimshot
    wl-clipboard

    (hiPrio clang_16)
    awscli2
    bc
    bind
    binutils
    bison
    cmake
    deno
    elfutils
    flex
    gcc
    gdb
    gh
    gnumake
    go_1_23
    goconvey
    gopls
    gofumpt
    gradle
    hyperfine
    # ipmiview
    nixpkgs-review
    nodejs
    linuxPackages.perf
    mvn2nix
    ncurses
    nodePackages.typescript-language-server
    perf-tools
    pkg-config
    python3
    ruby
    rustup
    # terraform
    boringtun
    onetun
    railway
    xclip
    xdg-desktop-portal-gtk

    # misc
    efibootmgr
    efitools
    i3lock
    inotify-tools
    lld
    lshw
    sbsigntool
    wal-g
    xorg.xeyes
    mkvtoolnix
    gnupg
  ];

  home.sessionVariables = sessionVariables;

  programs.atuin.enable = true;
  programs.home-manager.enable = true;
  programs.zsh = {
    enable = true;
    history = {
      save = 1000000;
    };
    sessionVariables = sessionVariables;
    shellAliases = {
      ls = "ls --color=auto";
      k = "kubectl";
    };
    initExtra = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source "${../shared/zsh/p10k.zsh}"
      source "${../shared/zsh/zshrc}"
      export PATH=$HOME/bin:$PATH
      command -v ngrok &>/dev/null && source <(ngrok completion)
    '';
  };

  programs.git = {
    enable = true;
    userName = "Euan Kemp";
    userEmail = "euank@" + "euan" + "k.com";
    aliases = {
      co = "checkout";
      s = "status";
    };
    extraConfig = {
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

    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = [ "*" ];
    };

    userDirs = {
      enable = true;
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
        "application/pdf" = "org.gnome.Evince.desktop";
      };

      defaultApplications = {
        "application/pdf" = [ "org.gnome.Evince.desktop" ];
      };
    };
  };

  home.stateVersion = "20.03";
}
