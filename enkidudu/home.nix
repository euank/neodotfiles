{
  config,
  pkgs,
  ...
}:

let
  jdkNixpkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/e021b8eea9a3fc87baa3f150753c3226436b67b9.tar.gz";
    sha256 = "1c1kqzjxanz47fp8pf4zsh8blfl1pdh9fy6ifcakvgy1zcm77jn4";
  }) { system = "x86_64-linux"; };
  torNixpkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/aed3de18b0dc3390bf1759afddce47c438e9877c.tar.gz";
    sha256 = "0yndxryw2yv3xrgjp6rjacwqc81scvsx3wb61k2wqgjpbcsazcp0";
  }) { system = "x86_64-linux"; };
  # for lsp server support, remove once nvim is 0.5 in nixpkgs
  # and msgpack 1.0
  nightlyNvimNix = (import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/48d6448ec2bcef0c29cdf91a4339dcb2fa0b0f02.tar.gz";
    sha256 = "1gla32h0scxd0dixg44cbc90lcfdvk33154amw43b2mvi9nk9h3n";
  }) {
    system = "x86_64-linux";
  });
  nightlyNvim = nightlyNvimNix.neovim.override { extraPython3Packages = (ps: [ ps.msgpack ]); };
  # nixatom = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/b8988e13be291029c72b76549d70c783856f2dc3.tar.gz") {};
  sessionVariables = {
    EDITOR = "nvim";
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig:${pkgs.opencv4}/lib/pkgconfig:${pkgs.xorg.libX11.dev}/lib/pkgconfig:${pkgs.xorg.libXrandr.dev}/lib/pkgconfig:${pkgs.xorg.libxcb.dev}/lib/pkgconfig";
    LIBCLANG_PATH = "${pkgs.llvmPackages.libclang}/lib";
    GTK_IM_MODULE = "ibus";
    XMODIFIERS = "@im=ibus";
    QT_IM_MODULE = "ibus";
  };
in
{
  home.packages = with pkgs; [
    anki
    bemenu
    binutils
    blueman
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
    gmrun
    gnome3.cheese
    htop
    ibus-engines.mozc
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
    torNixpkgs.tor-browser-bundle-bin
    tree
    unzip
    x11
    xorg.xkill
    xorg.xwininfo
    xwayland
    yacreader
    youtube-dl
    zsh-powerlevel10k

    # dev stuff
    (hiPrio clang)
    (pkgs.lib.hiPrio jdkNixpkgs.openjdk14)
    awscli2
    bind
    binutils
    cmake
    gcc
    gdb
    gnumake
    go
    gopls
    gradle
    ipmiview
    linuxPackages.perf
    nightlyNvim
    nodePackages.typescript-language-server
    perf-tools
    pkg-config
    python3
    qt5Full
    ruby
    rustup
    terraform

    # game related
    desmume
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
      source "${./zsh/p10k.zsh}"
      source "${./zsh/zshrc}"
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
