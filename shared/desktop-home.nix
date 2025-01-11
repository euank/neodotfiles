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
    nemo
    yazi
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

    screenshot-area
    llm-ocr-area

    tmux
    xsel
    xorg.xkill
    xorg.xwininfo
    yacreader
  ];

  home.file.".aspell.conf".text = "data-dir ${pkgs.aspell}/lib/aspell";

  home.sessionVariables = sessionVariables;

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      window-decoration = false;
      window-theme = "system";
      gtk-titlebar = false;
      gtk-wide-tabs = false;
      gtk-adwaita = false;
    };
  };

  services.status-notifier-watcher.enable = true;

  services.dunst.enable = true;

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
