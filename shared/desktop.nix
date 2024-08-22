{ pkgs, inputs, ... }:

# desktop.nix contains shared configuration for a machine which runs a desktop
# environment. The desktop environment is x11, and the actual window manager is
# managed by home-manager.

{
  imports = [ ./base.nix ];

  programs.hyprland.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.greetd.tuigreet}/bin/tuigreet \
            --time \
            --asterisks \
            --user-menu \
            --cmd Hyprland
        '';
      };
    };
  };
  environment.etc."greetd/environments".text = ''
    Hyprland
    zsh
  '';

  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  };
  programs.zsh.enable = true;
  qt.enable = true;
  qt.platformTheme = "lxqt";

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
        bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.enable-hw-volume"] = true,
        ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
        }
      '')
    ];
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
      noto-fonts-cjk
      noto-fonts-emoji
      ubuntu_font_family
    ];
  };

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-gtk
        fcitx5-mozc
        fcitx5-tokyonight
      ];
    };
  };

  time.timeZone = "Asia/Tokyo";

  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  programs.ssh.startAgent = false;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.gnome-disks.enable = true;

  environment.systemPackages = with pkgs; [
    alacritty
    blueman
    dmenu
    gnupg
    helvum
    meslo-lg
    pcsclite
    gparted
    wofi
  ];
}
