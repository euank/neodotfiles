{ pkgs, ... }:

# desktop.nix contains shared configuration for a machine which runs a desktop
# environment. The desktop environment is x11, and the actual window manager is
# managed by home-manager.

{
  imports = [ ./base.nix ];
  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    xkb.layout = "us";
  };
  programs.niri.enable = true;
  programs.xwayland.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-wlr
    ];
    config.niri = {
      # gnome has a working window-picker, wlr doesn't, use gnome.
      "org.freedesktop.impl.portal.ScreenCast" = "gnome";
    };
    config.common.default = [ "*" ];
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  };
  programs.zsh.enable = true;
  qt.enable = true;
  qt.platformTheme = "lxqt";

  services.gnome.gnome-keyring.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      freefont_ttf
      unifont
      comic-neue
      corefonts
      dejavu_fonts
      hanazono
      kanji-stroke-order-font
      libre-franklin
      meslo-lg
      meslolgs-nf
      migu
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      ubuntu_font_family
      takao
    ];
  };

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-gtk
        fcitx5-mozc
        fcitx5-tokyonight
      ];
      ignoreUserConfig = true;
      waylandFrontend = true;
      settings.globalOptions = {
        Hotkey = {
          EnumerateWithTriggerKeys = "True";
          EnumerateSkipFirst = "False";
        };
        "Hotkey/TriggerKeys" = {
          "0" = "Control+grave";
        };
        "Hotkey/PrevPage" = {
          "0" = "Up";
        };
        "Hotkey/NextPage" = {
          "0" = "Down";
        };
        "Hotkey/PrevCandidate" = {
          "0" = "Shift+Tab";
        };
        "Hotkey/NextCandidate" = {
          "0" = "Tab";
        };
        Behavior = {
          PreeditEnabledByDefault = "True";
          ShowInputMethodInformation = "True";
          CompactInputMethodInformation = "True";
          ShowFirstInputMethodInformation = "True";
          DefaultPageSize = "8";
          PreloadInputMethod = "True";
        };
      };
      settings.inputMethod = {
        "Groups/0" = {
          "Name" = "Default";
          "Default Layout" = "us";
          "DefaultIM" = "mozc";
        };
        "Groups/0/Items/0" = {
          "Name" = "keyboard-us";
          "Layout" = null;
        };
        "Groups/0/Items/1" = {
          "Name" = "mozc";
          "Layout" = null;
        };
        "GroupOrder" = {
          "0" = "Default";
        };
      };
    };
  };

  time.timeZone = "Asia/Tokyo";

  services.udev.packages = [ pkgs.yubikey-personalization ];

  programs.dconf.enable = true;
  programs.ssh.startAgent = false;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.gnome-disks.enable = true;

  environment.systemPackages = with pkgs; [
    blueman
    dmenu
    rmenu
    fuzzel
    gnupg
    gparted
    helvum
    meslo-lg
    niri
    pcsclite
  ];
}
