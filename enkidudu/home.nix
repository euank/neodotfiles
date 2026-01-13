{
  config,
  inputs,
  pkgs,
  ...
}:

let
  muttoauth2 = pkgs.writeShellApplication {
    name = "muttoauth2";
    runtimeInputs = with pkgs; [
      python3
      mutt
    ];
    text = ''
      python3 ${pkgs.mutt}/share/doc/mutt/samples/mutt_oauth2.py "$@"
    '';
  };
in
{
  imports = [
    ../shared/desktop-home.nix
    ../shared/vim/vim.nix
  ];

  home.packages = with pkgs; [
    calibre
    handbrake
    nickel
    android-tools

    # vlc

    # tic-80
    youki
    stdenv.cc.cc.lib
    ipmitool
    aegisub
    yarn
    terraform
    # desmume
    # jetbrains.idea-community
    # melonDS
    # minecraft
    muttoauth2
    # temporary: https://github.com/NixOS/nixpkgs/pull/386738
    # neomutt
    prismlauncher
    # tic-80
    ninja
    restic
    tor-browser
    wine
    winetricks
    zoom-us
  ];

  services.network-manager-applet = {
    enable = true;
  };
  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    enableSshSupport = true;
  };

  services.blueman-applet.enable = true;

  services.pasystray = {
    # tmp
    # enable = true;
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
