# home-manager configuration for a machine with a desktop (i.e. a display attached)

{ config, pkgs, ... }:

let
  sessionVariables = {
    EDITOR = "nvim";
    GLFW_SO_PATH = "${pkgs.glfw3}/lib/libglfw.so";
    OPENAL_SO_PATH = "${pkgs.openal}/lib/libopenal.so";
  };
in
{
  imports = [ ./home.nix ];

  home.packages = with pkgs; [
    # chromium
    # obs-studio
    anyrun
    swaylock

    (aspellWithDicts (ps: with ps; [ en ]))
    networkmanagerapplet
    anki
    arandr
    dmenu
    bemenu
    blueman
    deluge
    discord
    escrotum
    evince
    feh
    firefox
    gimp
    gmrun
    gnome-icon-theme
    gnome-session
    cheese
    google-chrome
    gptfdisk
    inkscape
    keepassxc
    # logseq # temp
    mpv
    nitrogen
    okular
    pavucontrol
    pulseaudioFull
    # Temporary: https://github.com/NixOS/nixpkgs/issues/367870
    # shotcut
    openshot-qt
    signal-desktop
    tree
    tig
    unzip
    tmux
    xsel
    xorg.xkill
    xorg.xwininfo
    yacreader
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

  services.status-notifier-watcher.enable = true;

  services.dunst.enable = true;

  services.flameshot.enable = true;

  systemd.user.services.maestral = {
    Unit = {
      Description = "Maestral daemon";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.maestral}/bin/maestral start -f";
      ExecStop = "${pkgs.maestral}/bin/maestral stop";
      Restart = "on-failure";
      Nice = 10;
    };
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.graphite-gtk-theme;
      name = "Graphite-Light";
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.graphite-cursors;
    name = "graphite-light";
    size = 12;
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-gtk
        fcitx5-mozc
        fcitx5-tokyonight
      ];
    };
  };

  home.stateVersion = "20.03";
}
