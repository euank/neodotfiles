{ pkgs, inputs, ... }:

# desktop.nix contains shared configuration for a machine which runs a desktop
# environment. The desktop environment is x11, and the actual window manager is
# managed by home-manager.

{
  imports = [ ./base.nix ];
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    # Not totally sure why I need this.
    # Effectively, we're handing things off to a home-manager managed window
    # manager setup. We don't actually use the xterm environment.
    desktopManager.xterm.enable = true;
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  # Vivarium setup, if I ever want to switch back to it..
  # services.xserver.displayManager.sessionPackages = [ pkgs.vivarium ];
  # environment.systemPackages = with pkgs; [ vivarium ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  };
  programs.zsh.enable = true;
  qt.enable = true;
  qt.platformTheme = "lxqt";

  # hardware.pulseaudio = {
  #   support32Bit = true;
  #   enable = true;
  #   package = pkgs.pulseaudioFull;
  # };
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
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [
      mozc
      uniemoji
    ];
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
  ];
}
