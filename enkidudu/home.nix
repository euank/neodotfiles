{
  config,
  pkgs,
  ...
}:

let
  # nixatom = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/b8988e13be291029c72b76549d70c783856f2dc3.tar.gz") {};
  sessionVariables = {
    EDITOR = "nvim";
    PKG_CONFIG_PATH =
      "${pkgs.openssl.dev}/lib/pkgconfig:${pkgs.opencv4}/lib/pkgconfig:${pkgs.xorg.libX11.dev}/lib/pkgconfig:${pkgs.xorg.libXrandr.dev}/lib/pkgconfig:${pkgs.xorg.libxcb.dev}/lib/pkgconfig:${pkgs.libopus.dev}/lib/pkgconfig";
    LIBCLANG_PATH = "${pkgs.llvmPackages.libclang}/lib";
    GTK_IM_MODULE = "ibus";
    XMODIFIERS = "@im=ibus";
    QT_IM_MODULE = "ibus";
    NIX_DEBUG_INFO_DIRS = "/run/dwarffs";
    PROTOC = "${pkgs.protobuf}/bin/protoc";
  };
in
{
  home.packages = with pkgs; [
    anki-bin
    bemenu
    binutils
    blender
    blueman
    borgbackup
    chromium
    deluge
    discord
    escrotum
    evince
    feh
    ffmpeg-full
    file
    firefox
    fish
    gimp
    gmrun
    gnome3.cheese
    htop
    inkscape
    jmtpfs
    jq
    k3s
    keepassxc
    kubectl
    kubernetes-helm
    mpv
    ngrok
    nitrogen
    nix-index
    nixpkgs-fmt
    nmap
    obs-studio
    openssl
    p7zip
    pass
    pavucontrol
    pwgen
    ripgrep
    scrot
    sqlite
    sshfs
    syncplay
    tig
    tint2
    tmux
    tor-browser-bundle-bin
    tree
    unzip
    x11
    neovim
    xorg.xkill
    xorg.xwininfo
    xwayland
    yacreader
    youtube-dl
    yt-dlp
    zsh-powerlevel10k
    signal-desktop

    # dev stuff
    (hiPrio clang)
    openjdk17
    awscli2
    bind
    binutils
    cmake
    gcc
    nodejs
    gdb
    gh
    gnumake
    go
    gopls
    gradle
    # ipmiview
    kpt
    linuxPackages.perf
    nodePackages.typescript-language-server
    perf-tools
    pkg-config
    python3
    qt5Full
    ruby
    rustup
    terraform
    pulumi
    pulumi-sdk
    kube2pulumi
    crd2pulumi
    mvn2nix
    gradle2nix
    idea.idea-community
    coldsnap

    # game related
    desmume
    # maptool
    melonDS
    minecraft

    # misc
    efitools
    sbsigntool
  ];

  home.sessionVariables = sessionVariables;

  programs.alacritty = {
    enable = true;
    settings = {
      env = {
        # TERM = "xterm-256color";
      };
      font = {
        normal = {
          family = "MesloLGS NF";
        };
      };
      colors = {
        primary = {
          background= "#000000";
          foreground= "#eaeaea";
          dim_foreground= "#9a9a9a";
          bright_foreground= "#ffffff";
        };
        normal = {
          black=   "#000000";
          red=     "#d54e53";
          green=   "#b9ca4a";
          yellow=  "#e6c547";
          blue=    "#7aa6da";
          magenta= "#c397d8";
          cyan=    "#70c0ba";
          white=   "#eaeaea";
        };
      };
    };
  };

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
  };

  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;

  programs.pazi = {
    enable = true;
    enableZshIntegration = true;
  };

  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    enableSshSupport = true;
    pinentryFlavor = "curses";
  };

  services.blueman-applet.enable = true;

  services.dropbox.enable = true;

  services.picom.enable = true;

  xsession.enable = true;
  xsession.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
    config = ./xmonad/xmonad.hs;
  };

  services.screen-locker = {
    enable = true;
    lockCmd = "${pkgs.i3lock}/bin/i3lock";
  };

  services.polybar = {
    enable = true;
    script = "polybar top &";
    config = {
      "bar/top" = {
        width = "100%";
        height = "3%";
        # radius = 0;
        tray-position  = "right";
        modules-center = "date";
      };
      "module/date" = {
        type = "internal/date";
        internal = 5;
        date = "%d.%m.%y";
        time = "%H:%M";
        label = "%time%  %date%";
      };
    };
  };

  services.pasystray = {
    enable = true;
  };

  systemd.user.services.nitrogen = {
    Unit = {
      Description = "Nitrogen";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.nitrogen}/bin/nitrogen --random --head=-1 --set-tiled /home/esk/Images/wallpaper";
    };
    Install = { WantedBy = [ "graphical-session.target" ]; };
  };

  systemd.user.services.ibus = {
    Unit = {
      Description = "ibus";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.ibus}/bin/ibus-daemon --xim";
    };
    Install = { WantedBy = [ "graphical-session.target" ]; };
  };

  xdg = {
    enable = true;

    userDirs = {
      enable      = true;
      desktop     = "$HOME/Desktop";
      download    = "$HOME/Downloads";
      documents   = "$HOME/Documents";
      templates   = "$HOME/Templates";
      music       = "$HOME/Music";
      videos      = "$HOME/Videos";
      pictures    = "$HOME/Pictures";
      publicShare = "$HOME/share/public";
    };

    desktopEntries = {
      firefox-def = {
        name = "Firefox Default Profile";
        genericName = "Web Browser";
        exec = "firefox -P default %U";
        terminal = false;
        categories = [ "Application" "Network" "WebBrowser" ];
        mimeType = [
          "text/html"
          "text/xml"
          "application/xhtml+xml"
          "application/vnd.mozilla.xul+xml"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
          "x-scheme-handler/ftp"
        ];
      };
    };

    mimeApps = {
      enable = true;
      associations.added = {
        "image/png"       = "feh.desktop";
        "image/jpeg"      = "feh.desktop";
        "application/pdf" = "org.gnome.Evince.desktop";
      };

      defaultApplications = {
        "text/html"                = [ "firefox-def.desktop" ];
        "x-scheme-handler/http"    = [ "firefox-def.desktop" ];
        "x-scheme-handler/https"   = [ "firefox-def.desktop" ];
        "x-scheme-handler/about"   = [ "firefox-def.desktop" ];
        "x-scheme-handler/unknown" = [ "firefox-def.desktop" ];
      };
    };

  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.03";
}
