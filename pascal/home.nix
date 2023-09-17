{ config, pkgs, ...  }:

let
  sessionVariables = {
    EDITOR = "nvim";
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig:${pkgs.opencv4}/lib/pkgconfig:${pkgs.xorg.libX11.dev}/lib/pkgconfig:${pkgs.xorg.libXrandr.dev}/lib/pkgconfig:${pkgs.xorg.libxcb.dev}/lib/pkgconfig:${pkgs.udev.dev}/lib/pkgconfig";
    GTK_IM_MODULE = "ibus";
    XMODIFIERS = "@im=ibus";
    QT_IM_MODULE = "ibus";
  };
  ibus = pkgs.ibus-with-plugins.override { plugins = with pkgs.ibus-engines; [ mozc uniemoji ]; };
in
{
  home.packages = with pkgs; [
    evince
    feh
    firefox
    gnome.cheese
    mpv
    nitrogen
    pavucontrol
    pwgen
    tint2
    ibus-engines.mozc
    obs-studio
    shotcut
    (aspellWithDicts (ps : with ps; [ en ]))
    trayer
    dmenu
    networkmanagerapplet
    gnome.gnome-session
    xsel
    gptfdisk
    escrotum
    brightnessctl
    eza
    file
    git
    gnumake
    htop
    iptables
    jq
    lsof
    nixpkgs-fmt
    openssl
    pkg-config
    python3
    ripgrep
    ruby
    sshfs
    tcpdump
    tig
    tmate
    tmux
    tree
    unzip
    zsh-powerlevel10k
    # boot
    sbsigntool
    efitools
  ];

  home.file.".aspell.conf".text = "data-dir ${pkgs.aspell}/lib/aspell";

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
    userEmail = "euank@euank.com";
  };

  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;

  programs.pazi = {
    enable = true;
    enableZshIntegration = true;
  };

  xsession.enable = true;
  xsession.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
    config = ../shared/xmonad/xmonad.hs;
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

  # Ibus
  systemd.user.services.ibus = {
    Unit = {
      Description = "ibus";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${ibus}/bin/ibus-daemon --xim";
    };
    Install = { WantedBy = [ "graphical-session.target" ]; };
  };

  home.stateVersion = "20.03";
}
