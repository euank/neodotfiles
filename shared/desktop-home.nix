# home-manager configuration for a machine with a desktop (i.e. a display attached)

{ pkgs, inputs, ... }:

{
  imports = [
    ./home.nix
    inputs.noctalia.homeModules.default
  ];

  home.packages = with pkgs; [
    # chromium
    # obs-studio
    anyrun
    aichat
    (aspellWithDicts (ps: with ps; [ en ]))
    networkmanagerapplet
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

    libreoffice
    keepassxc
    # logseq # temp
    mpv
    nemo
    yazi
    nitrogen
    kdePackages.okular
    kdePackages.kio-fuse
    kdePackages.kio-extras
    kdePackages.dolphin
    pavucontrol
    pulseaudioFull
    # Temporary: https://github.com/NixOS/nixpkgs/issues/367870
    # shotcut
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

  programs.anki = {
    enable = true;
    addons = with pkgs.ankiAddons; [
      anki-draw
      # colorful-tags
    ];
  };

  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;
    settings = {
      settingsVersion = 0;
      bar = {
        position = "top";
        monitors = [ ];
        density = "default";
        showOutline = false;
        showCapsule = true;
        capsuleOpacity = 1;
        backgroundOpacity = 0.93;
        useSeparateOpacity = false;
        floating = false;
        marginVertical = 4;
        marginHorizontal = 4;
        outerCorners = true;
        exclusive = true;
        widgets = {
          left = [
            {
              id = "Launcher";
            }
          ];
          center = [
            {
              id = "Clock";
            }
            {
              id = "Workspace";
            }
          ];
          right = [
            {
              id = "SystemMonitor";
            }
            {
              id = "ActiveWindow";
            }
            {
              id = "MediaMini";
            }
            {
              id = "Battery";
            }
            {
              id = "Volume";
            }
            {
              id = "Brightness";
            }
            {
              id = "ControlCenter";
            }
            {
              id = "Tray";
            }
            {
              id = "NotificationHistory";
            }
          ];
        };
      };
      general = {
        avatarImage = "";
        dimmerOpacity = 0.2;
        showScreenCorners = false;
        forceBlackScreenCorners = false;
        scaleRatio = 1;
        radiusRatio = 1;
        iRadiusRatio = 1;
        boxRadiusRatio = 1;
        screenRadiusRatio = 1;
        animationSpeed = 1;
        animationDisabled = false;
        compactLockScreen = false;
        lockOnSuspend = true;
        showSessionButtonsOnLockScreen = true;
        showHibernateOnLockScreen = false;
        enableShadows = true;
        shadowDirection = "bottom_right";
        shadowOffsetX = 2;
        shadowOffsetY = 3;
        language = "";
        allowPanelsOnScreenWithoutBar = true;
        showChangelogOnStartup = true;
        telemetryEnabled = true;
      };
      ui = {
        fontDefault = "";
        fontFixed = "";
        fontDefaultScale = 1;
        fontFixedScale = 1;
        tooltipsEnabled = true;
        panelBackgroundOpacity = 0.93;
        panelsAttachedToBar = true;
        settingsPanelMode = "attached";
        wifiDetailsViewMode = "grid";
        bluetoothDetailsViewMode = "grid";
        networkPanelView = "wifi";
        bluetoothHideUnnamedDevices = false;
        boxBorderEnabled = false;
      };
      location = {
        name = "Tokyo";
        weatherEnabled = true;
        weatherShowEffects = true;
        useFahrenheit = false;
        use12hourFormat = false;
        showWeekNumberInCalendar = false;
        showCalendarEvents = true;
        showCalendarWeather = true;
        analogClockInCalendar = false;
        firstDayOfWeek = -1;
        hideWeatherTimezone = false;
        hideWeatherCityName = false;
      };
      wallpaper = {
        enabled = true;
        overviewEnabled = false;
        directory = "";
        monitorDirectories = [ ];
        enableMultiMonitorDirectories = false;
        recursiveSearch = false;
        setWallpaperOnAllMonitors = true;
        fillMode = "crop";
        fillColor = "#000000";
        useSolidColor = false;
        solidColor = "#1a1a2e";
        randomEnabled = false;
        wallpaperChangeMode = "random";
        randomIntervalSec = 300;
        transitionDuration = 1500;
        transitionType = "random";
        transitionEdgeSmoothness = 0.05;
        panelPosition = "follow_bar";
        hideWallpaperFilenames = false;
        useWallhaven = false;
        wallhavenQuery = "";
        wallhavenSorting = "relevance";
        wallhavenOrder = "desc";
        wallhavenCategories = "111";
        wallhavenPurity = "100";
        wallhavenRatios = "";
        wallhavenApiKey = "";
        wallhavenResolutionMode = "atleast";
        wallhavenResolutionWidth = "";
        wallhavenResolutionHeight = "";
      };
      appLauncher = {
        enableClipboardHistory = false;
        autoPasteClipboard = false;
        enableClipPreview = true;
        clipboardWrapText = true;
        position = "center";
        pinnedApps = [ ];
        useApp2Unit = false;
        sortByMostUsed = true;
        terminalCommand = "xterm -e";
        customLaunchPrefixEnabled = false;
        customLaunchPrefix = "";
        viewMode = "list";
        showCategories = true;
        iconMode = "tabler";
        showIconBackground = false;
        ignoreMouseInput = false;
        screenshotAnnotationTool = "";
      };
      controlCenter = {
        position = "close_to_bar_button";
        diskPath = "/";
        shortcuts = {
          left = [
            {
              id = "Network";
            }
            {
              id = "Bluetooth";
            }
            {
              id = "WallpaperSelector";
            }
          ];
          right = [
            {
              id = "Notifications";
            }
            {
              id = "PowerProfile";
            }
            {
              id = "KeepAwake";
            }
            {
              id = "NightLight";
            }
          ];
        };
        cards = [
          {
            enabled = true;
            id = "profile-card";
          }
          {
            enabled = true;
            id = "shortcuts-card";
          }
          {
            enabled = true;
            id = "audio-card";
          }
          {
            enabled = false;
            id = "brightness-card";
          }
          {
            enabled = true;
            id = "weather-card";
          }
          {
            enabled = true;
            id = "media-sysmon-card";
          }
        ];
      };
      systemMonitor = {
        cpuWarningThreshold = 80;
        cpuCriticalThreshold = 90;
        tempWarningThreshold = 80;
        tempCriticalThreshold = 90;
        gpuWarningThreshold = 80;
        gpuCriticalThreshold = 90;
        memWarningThreshold = 80;
        memCriticalThreshold = 90;
        diskWarningThreshold = 80;
        diskCriticalThreshold = 90;
        cpuPollingInterval = 3000;
        tempPollingInterval = 3000;
        gpuPollingInterval = 3000;
        enableDgpuMonitoring = false;
        memPollingInterval = 3000;
        diskPollingInterval = 3000;
        networkPollingInterval = 3000;
        loadAvgPollingInterval = 3000;
        useCustomColors = false;
        warningColor = "";
        criticalColor = "";
        externalMonitor = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
      };
      dock = {
        enabled = true;
        position = "bottom";
        displayMode = "auto_hide";
        backgroundOpacity = 1;
        floatingRatio = 1;
        size = 1;
        onlySameOutput = true;
        monitors = [ ];
        pinnedApps = [ ];
        colorizeIcons = false;
        pinnedStatic = false;
        inactiveIndicators = false;
        deadOpacity = 0.6;
        animationSpeed = 1;
      };
      network = {
        wifiEnabled = true;
        bluetoothRssiPollingEnabled = false;
        bluetoothRssiPollIntervalMs = 10000;
        wifiDetailsViewMode = "grid";
        bluetoothDetailsViewMode = "grid";
        bluetoothHideUnnamedDevices = false;
      };
      sessionMenu = {
        enableCountdown = true;
        countdownDuration = 10000;
        position = "center";
        showHeader = true;
        largeButtonsStyle = false;
        largeButtonsLayout = "grid";
        showNumberLabels = true;
        powerOptions = [
          {
            action = "lock";
            enabled = true;
          }
          {
            action = "suspend";
            enabled = true;
          }
          {
            action = "hibernate";
            enabled = true;
          }
          {
            action = "reboot";
            enabled = true;
          }
          {
            action = "logout";
            enabled = true;
          }
          {
            action = "shutdown";
            enabled = true;
          }
        ];
      };
      notifications = {
        enabled = true;
        monitors = [ ];
        location = "top_right";
        overlayLayer = true;
        backgroundOpacity = 1;
        respectExpireTimeout = false;
        lowUrgencyDuration = 3;
        normalUrgencyDuration = 8;
        criticalUrgencyDuration = 15;
        enableKeyboardLayoutToast = true;
        saveToHistory = {
          low = true;
          normal = true;
          critical = true;
        };
        sounds = {
          enabled = false;
          volume = 0.5;
          separateSounds = false;
          criticalSoundFile = "";
          normalSoundFile = "";
          lowSoundFile = "";
          excludedApps = "discord,firefox,chrome,chromium,edge";
        };
      };
      osd = {
        enabled = true;
        location = "top_right";
        autoHideMs = 2000;
        overlayLayer = true;
        backgroundOpacity = 1;
        enabledTypes = [
          0
          1
          2
        ];
        monitors = [ ];
      };
      audio = {
        volumeStep = 5;
        volumeOverdrive = false;
        cavaFrameRate = 30;
        visualizerType = "linear";
        mprisBlacklist = [ ];
        preferredPlayer = "";
      };
      brightness = {
        brightnessStep = 5;
        enforceMinimum = true;
        enableDdcSupport = false;
      };
      colorSchemes = {
        useWallpaperColors = false;
        predefinedScheme = "Noctalia (default)";
        darkMode = true;
        schedulingMode = "off";
        manualSunrise = "06:30";
        manualSunset = "18:30";
        matugenSchemeType = "scheme-fruit-salad";
      };
      templates = {
        gtk = false;
        qt = false;
        kcolorscheme = false;
        alacritty = false;
        kitty = false;
        ghostty = false;
        foot = false;
        wezterm = false;
        fuzzel = false;
        discord = false;
        pywalfox = false;
        vicinae = false;
        walker = false;
        code = false;
        spicetify = false;
        telegram = false;
        cava = false;
        yazi = false;
        emacs = false;
        niri = false;
        hyprland = false;
        mango = false;
        zed = false;
        helix = false;
        zenBrowser = false;
        enableUserTemplates = false;
      };
      nightLight = {
        enabled = false;
        forced = false;
        autoSchedule = true;
        nightTemp = "4000";
        dayTemp = "6500";
        manualSunrise = "06:30";
        manualSunset = "18:30";
      };
      hooks = {
        enabled = false;
        wallpaperChange = "";
        darkModeChange = "";
        screenLock = "";
        screenUnlock = "";
        performanceModeEnabled = "";
        performanceModeDisabled = "";
      };
      desktopWidgets = {
        enabled = false;
        gridSnap = false;
        monitorWidgets = [ ];
      };
    };
  };

  home.file.".aspell.conf".text = "data-dir ${pkgs.aspell}/lib/aspell";

  systemd.user.services.xwayland-satellite = {
    Unit = {
      Description = "Xwayland outside your Wayland";
      BindsTo = "graphical-session.target";
      PartOf = "graphical-session.target";
      After = "graphical-session.target";
      Requisite = "graphical-session.target";
    };
    Service = {
      Type = "notify";
      NotifyAccess = "all";
      ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
      StandardOutput = "journal";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      clock = true;
      indicator = true;
      fade-in = "1";
      timestr = "%H:%M";
      datestr = "%Y年%m月%d日";
      font = "Takao Pゴシック";
    };
  };

  programs.niri.settings = {
    prefer-no-csd = true;
    animations.slowdown = 0.5;
    environment = {
      DISPLAY = ":0";
    };
    input = {
      focus-follows-mouse = {
        enable = true;
        max-scroll-amount = "0%";
      };
    };
    binds =
      (pkgs.lib.mapAttrs
        (_: str: {
          action.spawn = str;
        })
        {
          "Mod+T" = "alacritty";
          "Mod+Return" = "alacritty";
          "Mod+D" = [
            "rmenu"
            "-r"
            "drun"
          ];
          "Mod+Shift+D" = "wldash";
          "Mod+Ctrl+L" = "swaylock";
          "Mod+Print" = "llm-ocr-area";
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
        "Mod+Shift+Left" = "move-column-left";
        "Mod+Shift+Down" = "move-window-down";
        "Mod+Shift+Up" = "move-window-up";
        "Mod+Shift+Right" = "move-column-right";
        "Mod+Shift+H" = "move-column-left";
        "Mod+Shift+J" = "move-window-down";
        "Mod+Shift+K" = "move-window-up";
        "Mod+Shift+L" = "move-column-right";
        "Mod+Home" = "focus-column-first";
        "Mod+End" = "focus-column-last";
        "Mod+W" = "focus-monitor-left";
        "Mod+E" = "focus-monitor-right";
        "Mod+Shift+W" = "move-window-to-monitor-left";
        "Mod+Shift+E" = "move-window-to-monitor-right";
        "Mod+Shift+Ctrl+W" = "move-column-to-monitor-left";
        "Mod+Shift+Ctrl+E" = "move-column-to-monitor-right";

        "Mod+Shift+Home" = "move-column-to-first";
        "Mod+Shift+End" = "move-column-to-last";
        "Mod+Shift+Slash" = "show-hotkey-overlay";
        "Mod+Q" = "close-window";
        "Mod+Comma" = "consume-window-into-column";
        "Mod+Period" = "expel-window-from-column";
        "Mod+BracketLeft" = "consume-or-expel-window-left";
        "Mod+BracketRight" = "consume-or-expel-window-right";
        "Mod+R" = "switch-preset-column-width";
        "Mod+F" = "maximize-column";
        "Mod+Shift+F" = "fullscreen-window";
        "Mod+Shift+Q" = "quit";

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
              name = "Mod+Shift+${toString i}";
              value = {
                action."move-column-to-workspace" = i;
              };
            }
          ]) 10
        )
      ));

    spawn-at-startup = [
      {
        command = [
          "sh"
          "-c"
          "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE"
        ];
      }
    ];

    window-rules = [
      {
        matches = [
          {
            app-id = "steam";
            title = ''^notificationtoasts_\d+_desktop$'';
          }
        ];
        open-focused = false;
        default-floating-position = {
          x = -10;
          y = -10;
          relative-to = "top-right";
        };
      }
    ];
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
    type = "fcitx5";
    enable = true;
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
