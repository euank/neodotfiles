{ config, pkgs, ... }:

{
  imports = [
    ../shared/desktop-home.nix
    ../shared/vim/vim.nix
  ];

  home.packages = with pkgs; [
    # jetbrains.idea-community
    zoom-us
    # obs-studio
    yubikey-personalization-gui
    dia
    hicolor-icon-theme
    brightnessctl
    remmina
    (hiPrio bundler)
    slack

    # dev stuff
    docker
    docker-compose
    nodePackages.typescript-language-server
  ];

  services.network-manager-applet = {
    enable = true;
  };

  services.blueman-applet.enable = true;

  programs.zsh.initExtraFirst = ''
    export NGROK_HOME="/home/esk/dev/ngrok"
    source "/home/esk/dev/ngrok/.cache/ngrok-host-shellhook"
  '';

  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-gtk2;
  };

  programs.niri.settings.outputs."eDP-1" = {
    mode = {
      width = 2160;
      height = 1350;
      refresh = 60.0;
    };
    scale = 1.0;
  };

  xsession = {
    enable = false;
    preferStatusNotifierItems = true;
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      config = ../shared/xmonad/xmonad.hs;
    };
  };

  services.pasystray = {
    enable = true;
  };

  xdg = {
    desktopEntries = {
      # firefox-def = {
      #   name = "Firefox Default Profile";
      #   genericName = "Web Browser";
      #   # exec = "firefox -P default %U";
      #   # terminal = false;
      #   # categories = [ "Application" "Network" "WebBrowser" ];
      #   # mimeType = [
      #   #   "text/html"
      #   #   "text/xml"
      #   #   "application/xhtml+xml"
      #   #   "application/vnd.mozilla.xul+xml"
      #   #   "x-scheme-handler/http"
      #   #   "x-scheme-handler/https"
      #   #   "x-scheme-handler/ftp"
      #   # ];
      # };
    };

    mimeApps = {
      defaultApplications = {
        "text/html" = [ "firefox-def.desktop" ];
        "x-scheme-handler/http" = [ "firefox-def.desktop" ];
        "x-scheme-handler/https" = [ "firefox-def.desktop" ];
        "x-scheme-handler/about" = [ "firefox-def.desktop" ];
        "x-scheme-handler/unknown" = [ "firefox-def.desktop" ];
      };
    };
  };
}
