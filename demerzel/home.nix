{ config, pkgs, ... }:

let
  sessionVariables = {
    EDITOR = "nvim";
    NGROK_HOME = "/home/esk/dev/ngrok";
  };
in
{
  imports = [
    ../shared/desktop-home.nix
    ../shared/vim/vim.nix
  ];

  home.packages = with pkgs; [
    # jetbrains.idea-community
    zoom-us
    obs-studio
    shotcut
    yubikey-personalization-gui
    dia
    dmenu
    networkmanagerapplet
    gnome.gnome-session
    brightnessctl
    remmina
    (hiPrio bundler)
    slack
    yacreader

    # dev stuff
    docker
    docker-compose
    gnupg
    nodePackages.typescript-language-server
  ];

  home.file.".aspell.conf".text = "data-dir ${pkgs.aspell}/lib/aspell";

  home.sessionVariables = sessionVariables;

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      misc = {
        disable_hyprland_logo = true;
        new_window_takes_over_fullscreen = 1;
      };
      animations = {
        animation = "global,0";
      };
      master = {
        new_status = "master";
      };
      general = {
        gaps_in = "0";
        gaps_out = "0";
        layout = "master";
      };
      monitor = [ ",preferred,auto,1" ];
      "$mod" = "SUPER";
      "$terminal" = "alacritty";
      bind =
        [
          "$mod, return, exec, $terminal"
          "$mod_CTRL, l, exec, swaylock"
          "$mod, p, exec, anyrun"
          "$mod_SHIFT, c, killactive"
          "$mod, j, layoutmsg, cycleprev"
          "$mod, k, layoutmsg, cyclenext"
          "$mod, l, layoutmsg, mfact +0.05"
          "$mod, h, layoutmsg, mfact -0.05"
          "$mod, m, layoutmsg, orientationcycle"
          "$mod_SHIFT, j, layoutmsg, swapprev"
          "$mod_SHIFT, k, layoutmsg, swapnext"
          "$mod_SHIFT, return, layoutmsg, swapwithmaster master"
          "$mod, w, focusmonitor,0"
          "$mod, e, focusmonitor,1"
          "$mod_SHIFT, w, movewindow,mon:0"
          "$mod_SHIFT, e, movewindow,mon:1"
          "$mod, f, fullscreen,1"
          "$mod_SHIFT, f, fullscreen"
          ", Print, exec, grimblast copy area"
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
          builtins.concatLists (
            builtins.genList (
              x:
              let
                ws =
                  let
                    c = (x + 1) / 10;
                  in
                  builtins.toString (x + 1 - (c * 10));
              in
              [
                "$mod, ${ws}, focusworkspaceoncurrentmonitor, ${toString (x + 1)}"
                "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
              ]
            ) 10
          )
        );
    };
  };

  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-gtk2;
  };

  services.picom.enable = true;

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
