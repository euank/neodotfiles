{ config, pkgs, ...  }:

let
  sessionVariables = {
    EDITOR = "nvim";
    GTK_IM_MODULE = "ibus";
    XMODIFIERS = "@im=ibus";
    QT_IM_MODULE = "ibus";
  };
in
{
  imports = [
    ../shared/desktop-home.nix
    ../shared/vim/vim.nix
  ];
  home.packages = with pkgs; [
    zoom-us
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

  home.file.".aspell.conf".text = "data-dir ${pkgs.aspell}/lib/aspell";

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

  services.picom.enable = true;

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
