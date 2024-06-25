{ config, pkgs, ... }:

{
  imports = [ ../shared/desktop-home.nix ];
  home.packages = with pkgs; [
    (aspellWithDicts (ps: with ps; [ en ]))
    gnome.gnome-session
    xsel
    gptfdisk
    escrotum
    brightnessctl
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
    zsh-powerlevel10k
    # boot
    sbsigntool
    efitools
  ];

  home.file.".aspell.conf".text = "data-dir ${pkgs.aspell}/lib/aspell";

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
          background = "#000000";
          foreground = "#eaeaea";
          dim_foreground = "#9a9a9a";
          bright_foreground = "#ffffff";
        };
        normal = {
          black = "#000000";
          red = "#d54e53";
          green = "#b9ca4a";
          yellow = "#e6c547";
          blue = "#7aa6da";
          magenta = "#c397d8";
          cyan = "#70c0ba";
          white = "#eaeaea";
        };
      };
    };
  };

  programs.home-manager.enable = true;
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
        tray-position = "right";
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

  home.stateVersion = "20.03";
}
