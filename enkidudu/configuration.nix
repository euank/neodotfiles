{ pkgs, inputs, config, ... }:

let
  inherit (inputs) home-manager dwarffs;
in
{
  # disabledModules = [ "virtualisation/libvirtd.nix" ];
  imports = [
    ./hardware-configuration.nix
    ../shared/base.nix
    home-manager.nixosModules.home-manager
    dwarffs.nixosModules.dwarffs
  ];

  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];

  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  hardware.pulseaudio.support32Bit = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.unifi.enable = false;

  services.postgresql = {
    enable = false;
    package = pkgs.postgresql_11;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      local all all trust
      host all all ::1/128 trust
    '';
    initialScript = pkgs.writeText "backend-initScript" ''
      CREATE DATABASE dev;
    '';
  };
  services.nginx = {
    enable = false;
    appendHttpConfig = ''
      types {
        application/wasm wasm;
      }
    '';
    virtualHosts."dev.lan" =  {
      enableACME = false;
      forceSSL = false;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
      };
    };
  };
  networking.extraHosts = ''
    127.0.0.1 dev.lan
  '';


  # As in the the ttgl mecha
  networking.hostName = "Enkidudu";
  networking.hostId = "373650f1";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      dejavu_fonts
      meslolgs-nf
      meslo-lg
      migu
      hanazono
      comic-neue
      corefonts
    ];
  };
  programs.gnome-disks.enable = true;
  programs.adb.enable = true;
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  programs.ssh.startAgent = false;
  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  networking.useDHCP = false;
  networking.interfaces.enp8s0.useDHCP = true;
  networking.interfaces.wlp6s0.useDHCP = false;
  networking.firewall.enable = false;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ mozc uniemoji ];
  };

  time.timeZone = "America/Los_Angeles";

  environment.systemPackages = with pkgs; [
    blueman
    vim
    dmenu alacritty
    gnupg
    pcsclite
    pinentry-curses
    meslo-lg
    pkg-config
    openssl.dev
    openssl
    # vivarium
  ];

  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };
  hardware.opengl.driSupport = true;
  hardware.opengl.enable = true;

  # x11
  # Xmonad setup
  services.xserver.layout = "us";
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];
  # services.xserver.xrandrHeads = [
  #   "DisplayPort-1"
  #   "DisplayPort-0"
  # ];
  # Unclear why I need this.
  services.xserver.desktopManager.xterm.enable = true;
  # Vivarium setup
  # services.xserver.displayManager.sessionPackages = [ pkgs.vivarium ];

  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  virtualisation.docker.enable = true;

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  virtualisation.libvirtd.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.esk.extraGroups = [ "dwarffs" ];

  home-manager.users.esk = import ./home.nix;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}
