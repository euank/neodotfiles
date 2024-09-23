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
    wal-g
    stdenv.cc.cc.lib
    lld
    ipmitool
    aegisub
    yarn
    desmume
    # jetbrains.idea-community
    melonDS
    # minecraft
    mkvtoolnix
    muttoauth2
    neomutt
    prismlauncher
    thedesk
    ninja
    restic
    tor-browser-bundle-bin
    yacreader
    zoom-us
  ];

  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    enableSshSupport = true;
  };

  services.blueman-applet.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      misc = {
        disable_hyprland_logo = true;
        new_window_takes_over_fullscreen = 1;
        exit_window_retains_fullscreen = true;
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
      monitor = [
        "DP-3,2560x1440,1440x560,1"
        "HDMI-A-1,2560x1440,0x0,1,transform,1"
        ",preferred,auto,1"
      ];
      "$mod" = "SUPER";
      "$terminal" = "alacritty";
      bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
      ];
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
          "$mod, t, togglefloating"
          "$mod_SHIFT, f, fullscreen"
          ", Print, exec, grimshot copy area"
          "SHIFT, Print, exec, grimshot copy active"
          "$mod, Print, exec, grimshot copy screen"
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
