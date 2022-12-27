# home-manager configuration for a machine without a desktop, i.e. a headless server,
# but still with my dev setup

{config, pkgs, ...}:

let
  sessionVariables = {
    EDITOR = "nvim";
    PKG_CONFIG_PATH =
      "${pkgs.openssl.dev}/lib/pkgconfig:${pkgs.opencv4}/lib/pkgconfig:${pkgs.xorg.libX11.dev}/lib/pkgconfig:${pkgs.xorg.libXrandr.dev}/lib/pkgconfig:${pkgs.xorg.libxcb.dev}/lib/pkgconfig:${pkgs.libopus.dev}/lib/pkgconfig:${pkgs.sqlite.dev}/lib/pkgconfig:${pkgs.udev.dev}/lib/pkgconfig:${pkgs.pam}/lib/pkgconfig:${pkgs.elfutils.dev}/lib/pkgconfig:${pkgs.ncurses.dev}/lib/pkgconfig";
    LIBCLANG_PATH = "${pkgs.llvmPackages.libclang}/lib";
    NIX_DEBUG_INFO_DIRS = "/run/dwarffs";
    PROTOC = "${pkgs.protobuf}/bin/protoc";

    COWPATH = "${pkgs.cowsay}/share/cows:${pkgs.tewisay}/share/tewisay/cows";
  };
in
{
  home.packages = with pkgs; [
    bazel_5
    binutils
    borgbackup
    cfssl
    cntr
    cowsay
    diskonaut
    dua
    escrotum
    figlet
    file
    fish
    flyctl
    heaptrack
    htop
    jmtpfs
    jq
    k3s
    kubectl
    kubernetes-helm
    ngrok
    nickel
    nitrogen
    nix-index
    nixpkgs-fmt
    nmap
    openssl
    p7zip
    pass
    pavucontrol
    pwgen
    redis
    ripgrep
    rust-analyzer
    sqlite
    sqlite.dev
    sshfs
    tewisay
    tig
    tmux
    toilet
    tree
    unzip
    wasm-pack
    wireguard-tools
    wireshark
    yt-dlp
    zsh-powerlevel10k

    (hiPrio clang)
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
    go_1_19
    gopls
    gradle
    hyperfine
    # ipmiview
    openjdk
    nodejs
    gradle2nix
    kpt
    linuxPackages.perf
    mvn2nix
    ncurses
    nodePackages.typescript-language-server
    perf-tools
    pkg-config
    python3
    ruby
    rustup
    terraform

    # misc
    efitools
    sbsigntool
  ];

  home.sessionVariables = sessionVariables;

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

  home.stateVersion = "20.03";
}
