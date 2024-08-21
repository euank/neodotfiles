{ config, pkgs, ... }:

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
        new_is_master = false;
      };
      general = {
        gaps_in = "0";
        gaps_out = "0";
      };
      monitor = [
        ",preferred,auto,1"
      ];
      "$mod" = "SUPER";
      "$terminal" = "alacritty";
      bind = [
        "$mod, return, exec, $terminal"
        "$mod_CTRL, l, exec, swaylock"
        "$mod, p, exec, anyrun"
        "$mod_SHIFT, c, killactive"
        "$mod, j, cyclenext,prev"
        "$mod, k, cyclenext"
        "$mod, w, focusmonitor,0"
        "$mod, e, focusmonitor,1"
        "$mod_SHIFT, w, movewindow,mon:0"
        "$mod_SHIFT, e, movewindow,mon:1"
        "$mod, f, fullscreen,1"
        "$mod_SHIFT, f, fullscreen"
        ", Print, exec, grimblast copy area"
      ] ++ (
        # workspaces
        # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
        builtins.concatLists (builtins.genList (
          x: let
            ws = let
              c = (x + 1) / 10;
            in
            builtins.toString (x + 1 - (c * 10));
          in [
            "$mod, ${ws}, focusworkspaceoncurrentmonitor, ${toString (x + 1)}"
            "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
          ]
        ) 10)
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

  xsession.enable = true;
  xsession.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
    config = ../shared/xmonad/xmonad.hs;
  };

  services.screen-locker = {
    enable = true;
    lockCmd = "${pkgs.i3lock}/bin/i3lock";
  };

  services.polybar = {
    enable = true;
    script = "polybar top &";
    config = {
      "bar/top" = {
        width = "100%";
        height = "3%";
        # radius = 0;
        tray-position = "right";
        modules-center = "date";
      };
      "module/date" = {
        type = "internal/date";
        internal = 5;
        date = "%d.%m.%y";
        time = "%H:%M";
        label = "%time%  %date%";
      };
    };
  };

  services.pasystray = {
    enable = true;
  };

  # nitrogen
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
}
