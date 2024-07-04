# home-manager configuration for a machine with a desktop (i.e. a display attached)

{ config, pkgs, ... }:

let
  sessionVariables = {
    EDITOR = "nvim";
    GTK_IM_MODULE = "ibus";
    XMODIFIERS = "@im=ibus";
    QT_IM_MODULE = "ibus";
    GLFW_SO_PATH = "${pkgs.glfw3}/lib/libglfw.so";
    OPENAL_SO_PATH = "${pkgs.openal}/lib/libopenal.so";
  };
  ibus = pkgs.ibus-with-plugins.override {
    plugins = with pkgs.ibus-engines; [
      mozc
      uniemoji
    ];
  };
in
{
  imports = [ ./home.nix ];

  home.packages = with pkgs; [
    # chromium
    # ffmpeg-full
    # obs-studio

    (aspellWithDicts (ps: with ps; [ en ]))
    networkmanagerapplet
    anki
    arandr
    bemenu
    blueman
    calibre
    deluge
    discord
    escrotum
    evince
    feh
    firefox
    gimp
    gmrun
    cheese
    google-chrome
    gptfdisk
    ibus
    inkscape
    keepassxc
    # logseq # temp
    mpv
    nitrogen
    okular
    pavucontrol
    shotcut
    openshot-qt
    signal-desktop
    syncplay
    tint2
    tree
    tig
    unzip
    tmux
    xsel
    xorg.xkill
    xorg.xwininfo
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

  services.dunst.enable = true;

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
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  home.stateVersion = "20.03";
}
