{ pkgs, inputs, ... }:

# desktop.nix contains shared configuration for a machine which runs a desktop
# environment. The desktop environment is x11, and the actual window manager is
# managed by home-manager.

{
  services.xserver = {
    enable = true;
    layout = "us";
    # Not totally sure why I need this.
    # Effectively, we're handing things off to a home-manager managed window
    # manager setup. We don't actually use the xterm environment.
    desktopManager.xterm.enable = true;
  };
  # Vivarium setup, if I ever want to switch back to it..
  # services.xserver.displayManager.sessionPackages = [ pkgs.vivarium ];
  # environment.systemPackages = with pkgs; [ vivarium ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  };

  sound.enable = false;
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
  };
  environment.etc = {
    "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
      bluez_monitor.properties = {
      ["bluez5.enable-sbc-xq"] = true,
      ["bluez5.enable-msbc"] = true,
      ["bluez5.enable-hw-volume"] = true,
      ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
      }
    '';
  };
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      dejavu_fonts
      meslolgs-nf
      meslo-lg
      libre-franklin
      hanazono
      kanji-stroke-order-font
      migu
      comic-neue
      corefonts
      ubuntu_font_family
    ];
  };

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ mozc uniemoji ];
  };

  time.timeZone = "America/Los_Angeles";

  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  programs.ssh.startAgent = false;
  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  programs.gnome-disks.enable = true;

  environment.systemPackages = with pkgs; [
    alacritty
    blueman
    dmenu
    gnupg
    meslo-lg
    pcsclite
  ];
}
