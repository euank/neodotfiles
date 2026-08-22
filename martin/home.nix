{ config, pkgs, ... }:

{
  imports = [
    ../shared/desktop-home.nix
    ../shared/vim/vim.nix
  ];
  home.packages = with pkgs; [
    zoom-us
    hicolor-icon-theme
    brightnessctl
    (pkgs.lib.hiPrio bundler)
    slack

    # dev stuff
    docker
    docker-compose
  ];

  services.network-manager-applet = {
    enable = true;
  };

  home.file.".aspell.conf".text = "data-dir ${pkgs.aspell}/lib/aspell";

  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    enableSshSupport = true;
  };

  programs.niri.settings.outputs."eDP-1" = {
    mode = {
      width = 2560;
      height = 1440;
      refresh = 60.0;
    };
    scale = 1.0;
  };

  services.pasystray = {
    enable = true;
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
