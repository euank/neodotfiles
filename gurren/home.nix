{ config, pkgs, ... }:

{
  imports = [
    ../shared/desktop-home.nix
    ../shared/vim/vim.nix
  ];

  home.packages = with pkgs; [
    stdenv.cc.cc.lib
    ninja
    restic
    tor-browser-bundle-bin
    zoom-us
  ];

  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    enableSshSupport = true;
  };

  programs.niri.settings = {
    outputs."DP-3" = {
      mode = {
        width = 2560;
        height = 1440;
        refresh = 75.0;
      };
      position = {
        x = 1440;
        y = 550;
      };
    };
    outputs."HDMI-A-1" = {
      position = {
        x = 0;
        y = 0;
      };
      mode = {
        width = 2560;
        height = 1440;
        refresh = 75.0;
      };
      transform = {
        rotation = 90;
      };
    };
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
  };
}
