# home-manager configuration for a machine with a desktop (i.e. a display attached)

{ pkgs, ... }:

let
  sessionVariables = {
    EDITOR = "nvim";
    GLFW_SO_PATH = "${pkgs.glfw3}/lib/libglfw.so";
    OPENAL_SO_PATH = "${pkgs.openal}/lib/libopenal.so";
    DISPLAY = ":0"; # xwayland
  };
in
{
  imports = [
    ./home.nix
  ];

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
    # kdePackages.okular
    pavucontrol
    pulseaudioFull
    # Temporary: https://github.com/NixOS/nixpkgs/issues/367870
    # shotcut
    openshot-qt
    signal-desktop
    tree
    tig
    unzip

    libnotify
    swaynotificationcenter
    slurp
    grim
    screenshot-area
    llm-ocr-area
    sway-contrib.grimshot
    wl-clipboard
    wayout
    wlay
    xwayland-run
    xwayland-satellite

    wldash
    rmenu
    tmux
    xsel
    xorg.xkill
    xorg.xwininfo
    yacreader
  ];

  home.file.".aspell.conf".text = "data-dir ${pkgs.aspell}/lib/aspell";

  home.sessionVariables = sessionVariables;
  systemd.user.services.xwayland-satellite = {
    Unit = {
      Description = "Xwayland outside your Wayland";
      BindsTo     = "graphical-session.target";
      PartOf      = "graphical-session.target";
      After       = "graphical-session.target";
      Requisite   = "graphical-session.target";
    };
    Service = {
      Type           = "notify";
      NotifyAccess   = "all";
      ExecStart      = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
      StandardOutput = "journal";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  programs.niri.settings = {
    prefer-no-csd = true;
    input = {
      focus-follows-mouse = {
        enable            = true;
        max-scroll-amount = "0%";
      };
    };
    binds =
      (pkgs.lib.mapAttrs
        (_: str: {
          action.spawn = str;
        })
        {
          "Mod+T"       = "alacritty";
          "Mod+Return"  = "alacritty";
          "Mod+D"       = ["rmenu" "-r" "drun"];
          "Mod+Shift+D" = "wldash";
          "Super+L"     = "swaylock";
          "Mod+Print"   = "llm-ocr-area";
        }
      )
      // (pkgs.lib.mapAttrs (_: str: { action."${str}" = [ ]; }) {
        "Mod+Left" = "focus-column-left";
        "Mod+Down" = "focus-window-down";
        "Mod+Up" = "focus-window-up";
        "Mod+Right" = "focus-column-right";
        "Mod+H" = "focus-column-left";
        "Mod+J" = "focus-window-down";
        "Mod+K" = "focus-window-up";
        "Mod+L" = "focus-column-right";
        "Mod+Ctrl+Left" = "move-column-left";
        "Mod+Ctrl+Down" = "move-window-down";
        "Mod+Ctrl+Up" = "move-window-up";
        "Mod+Ctrl+Right" = "move-column-right";
        "Mod+Ctrl+H" = "move-column-left";
        "Mod+Ctrl+J" = "move-window-down";
        "Mod+Ctrl+K" = "move-window-up";
        "Mod+Ctrl+L" = "move-column-right";
        "Mod+Home" = "focus-column-first";
        "Mod+End" = "focus-column-last";
        "Mod+Shift+Left" = "focus-monitor-left";
        "Mod+Shift+Right" = "focus-monitor-right";
        "Mod+Shift+H" = "focus-monitor-left";
        "Mod+Shift+L" = "focus-monitor-right";
        "Mod+Shift+Ctrl+Left" = "move-column-to-monitor-left";
        "Mod+Shift+Ctrl+Right" = "move-column-to-monitor-right";
        "Mod+Shift+Ctrl+H" = "move-column-to-monitor-left";
        "Mod+Shift+Ctrl+L" = "move-column-to-monitor-right";

        "Mod+Ctrl+Home" = "move-column-to-first";
        "Mod+Ctrl+End" = "move-column-to-last";
        "Mod+Shift+Slash" = "show-hotkey-overlay";
        "Mod+Q" = "close-window";
        "Mod+Comma" = "consume-window-into-column";
        "Mod+Period" = "expel-window-from-column";
        "Mod+BracketLeft" = "consume-or-expel-window-left";
        "Mod+BracketRight" = "consume-or-expel-window-right";
        "Mod+R" = "switch-preset-column-width";
        "Mod+F" = "maximize-column";
        "Mod+Shift+F" = "fullscreen-window";
        "Mod+Shift+K" = "quit";

        "Print" = "screenshot";
        "Ctrl+Print" = "screenshot-screen";
        "Alt+Print" = "screenshot-window";
      })
      // (pkgs.lib.listToAttrs (
        pkgs.lib.flatten (
          builtins.genList (i: [
            {
              name = "Mod+${toString i}";
              value = {
                action."focus-workspace" = i;
              };
            }
            {
              name = "Mod+Ctrl+${toString i}";
              value = {
                action."move-column-to-workspace" = i;
              };
            }
          ]) 10
        )
      ));
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings =
      let
        niri = "${pkgs.niri}/bin/niri";
        swaync-client = "${pkgs.swaynotificationcenter}/bin/swaync-client";
      in
      {
        mainBar = {
          layer = "top";
          position = "top";
          modules-left = [
            "custom/right-arrow-dark"
            "niri/workspaces"
            # "niri/window"
            "mpris"
          ];
          modules-center = [
            "custom/left-arrow-dark"
            "clock"
            "custom/right-arrow-dark"
          ];
          modules-right = [
            "custom/left-arrow-dark"
            "pulseaudio"
            "bluetooth"
            "memory"
            "cpu"
            "battery"
            "disk"
            "custom/left-arrow-light"
            "network"
            "custom/notifications"
            "custom/left-arrow-dark"
            "tray"
          ];

          "niri/workspaces" = {
            all-outputs = false;
            format = "{icon}";
            # show workspace numbers as formal Japanese numerals
            format-icons = {
              "1" = "一";
              "2" = "二";
              "3" = "三";
              "4" = "四";
              "5" = "五";
              "6" = "六";
              "7" = "七";
              "8" = "八";
              "9" = "九";
              "10" = "十";
              default = "";
            };
            on-scroll-up = "${niri} msg action focus-workspace-up";
            on-scroll-down = "${niri} msg action focus-workspace-down";
          };

          "niri/window" = {
            separate-outputs = true;
            icon = true;
            format = "";
            rewrite = { };
          };

          "custom/left-arrow-dark" = {
            format = "";
            tooltip = false;
          };
          "custom/left-arrow-light" = {
            format = "";
            tooltip = false;
          };
          "custom/right-arrow-dark" = {
            format = "";
            tooltip = false;
          };
          "custom/right-arrow-light" = {
            format = "";
            tooltip = false;
          };
          "custom/notifications" = {
            format = "{icon}";
            tooltip = false;
            format-icons = {
              notification = "<span foreground='red'><sup></sup></span>";
              none = "";
              dnd-notification = "<span foreground='red'><sup></sup></span>";
              dnd-none = "";
              inhibited-notification = "<span foreground='red'><sup></sup></span>";
              inhibited-none = "";
              dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
              dnd-inhibited-none = "";
            };
            return-type    = "json";
            exec           = "${swaync-client} -swb";
            on-click       = "${swaync-client} -t -sw";
            on-click-right = "${swaync-client} -d -sw";
            escape         = true;
          };

          mpris = {
            format = "{player_icon} {status_icon} {dynamic}";
            format-playing = "{player_icon} {status_icon} {dynamic}";
            format-paused = "{player_icon} {status_icon} <i>{dynamic}</i>";
            format-stopped = "{player_icon} {status_icon} <i>{dynamic}</i>";
            dynamic-len = 30;
            player-icons = {
              default = "";
              mpv = "󰝚";
              firefox = "";
            };
            status-icons = {
              playing = "󰐊";
              paused = "󰏤";
              stopped = "󰓛";
            };
            on-scroll-down = "${pkgs.playerctl} next";
            on-scroll-up = "${pkgs.playerctl} previous";
          };
          network = {
            interface = "wlan0";
            format = "{ifname}";
            format-wifi = " ";
            format-ethernet = "󰈀 ";
            format-linked = "󱘖 ";
            format-disconnected = "󰣽 ";
            tooltip-format = "{ifname} via {gwaddr}";
            tooltip-format-wifi = "{essid} ({signalStrength}%)";
            tooltip-format-ethernet = "{ifname} {ipaddr}/{cidr}";
            tooltip-format-disconnected = "Disconnected";
            max-length = 50;
            on-click = "${pkgs.rmenu}/bin/rmenu -r network";
          };
          clock = {
            format = "{:%H:%M}";
            tooltip-format = "<tt><small>{calendar}</small></tt>";
            calendar = {
              mode = "year";
              mode-mon-col = 3;
              weeks-pos = "right";
              on-scroll = 1;
              on-click-right = "mode";
              format = {
                months = "<span color='#ffead3'><b>{}</b></span>";
                days = "<span color='#ecc6d9'><b>{}</b></span>";
                weeks = "<span color='#99ffdd'><b>W{}</b></span>";
                weekdays = "<span color='#ffcc66'><b>{}</b></span>";
                today = "<span color='#ff6699'><b><u>{}</u></b></span>";
              };
            };
            actions = {
              on-click-right = "mode";
              on-click-forward = "tz_up";
              on-click-backward = "tz_down";
              on-scroll-up = "shift_down";
              on-scroll-down = "shift_up";
            };
          };
          bluetooth = {
            format = " {num_connections}";
            tooltip-format = "{device_alias}: {status}";
          };
          pulseaudio = {
            format = "{icon}   {volume:2}%";
            format-bluetooth = "{icon}   {volume}%";
            format-muted = "󰝟";
            format-icons = {
              headphones = "";
              default = [
                ""
                ""
              ];
            };
            scroll-step = 5;
            max-volume = 250;
            on-click = "${pkgs.pamixer} -t";
            on-click-right = pkgs.pavucontrol;
            on-scroll-down = "${pkgs.wireplumber} set-volume -l 2.0 @DEFAULT_AUDIO_SINK@ 5%-";
            on-scroll-up = "${pkgs.wireplumber} set-volume -l 2.0 @DEFAULT_AUDIO_SINK@ 5%+";
          };
          memory = {
            interval = 5;
            format = "  {}%";
          };
          cpu = {
            interval = 5;
            format = "󱛟  {usage:2}%";
          };
          disk = {
            interval = 5;
            format = "󱛟  {percentage_used:2}%";
            path = "/";
          };
          tray = {
            icon-size = 20;
          };
        };
      };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      env = {
        # TERM = "xterm-256color";
      };
      font = {
        normal = {
          family = "MesloLGS NF";
        };
      };
      colors = {
        primary = {
          background = "#000000";
          foreground = "#eaeaea";
          dim_foreground = "#9a9a9a";
          bright_foreground = "#ffffff";
        };
        normal = {
          black = "#000000";
          red = "#d54e53";
          green = "#b9ca4a";
          yellow = "#e6c547";
          blue = "#7aa6da";
          magenta = "#c397d8";
          cyan = "#70c0ba";
          white = "#eaeaea";
        };
      };
    };
  };

  services.status-notifier-watcher.enable = true;

  systemd.user.services.swaync = {
    Unit = {
      Description = "notifications";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.swaynotificationcenter}/bin/swaync";
      Restart = "on-failure";
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
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-gtk
        fcitx5-mozc
        fcitx5-tokyonight
      ];
    };
  };

  home.stateVersion = "20.03";
}
