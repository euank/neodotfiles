{ config, pkgs, ... }:

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
    youki
    stdenv.cc.cc.lib
    ipmitool
    aegisub
    yarn
    desmume
    # jetbrains.idea-community
    melonDS
    # minecraft
    muttoauth2
    neomutt
    prismlauncher
    thedesk
    ninja
    restic
    tor-browser-bundle-bin
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

  xsession = {
    enable = true;
    preferStatusNotifierItems = true;
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      config = ../shared/xmonad/xmonad.hs;
    };
  };

  services.screen-locker = {
    enable = true;
    lockCmd = "${pkgs.i3lock}/bin/i3lock";
  };

  services.taffybar = {
    enable = true;
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
    Install = {
      WantedBy = [ "graphical-session.target" ];
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
