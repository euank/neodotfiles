{ pkgs, inputs, ... }:

let
  inherit (inputs) home-manager;
in
{
  imports = [
    ./hardware-configuration.nix
    home-manager.nixosModules.home-manager
    "${inputs.ngrok-dev2}/nixos/client-module.nix"
  ];
  # (;_;)


  fileSystems."/".options = ["noatime" "nodiratime" "discard" ];

  hardware.enableRedistributableFirmware = true;
  boot.kernel.sysctl."fs.inotify.max_user_instances" = 8192;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  hardware.bluetooth.enable = true;
  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ mozc uniemoji ];
  };
  boot.supportedFilesystems = [ "zfs" ];

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/e5624a65-5c32-4761-847a-8deda806714c";
      preLVM = true;
      allowDiscards = true;
    };
  };

  networking.hostName = "rolivaw"; # R. Olivaw
  networking.hostId = "473650f1";
  networking.networkmanager.enable = true;

  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      dejavu_fonts
      meslolgs-nf
      meslo-lg
      migu
      hanazono
      corefonts
    ];
  };
  programs.gnome-disks.enable = true;
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };


  time.timeZone = "America/Los_Angeles";

  environment.systemPackages = with pkgs; [
    curl wget vim neovim
    networkmanagerapplet
    firefox
    trayer
    dmenu
    gnumake
    tint2 pass
    gnome3.gnome-session
    docker docker_compose
    xsel
    libvirt
    ripgrep
    rustup
    gcc tig binutils go file tree
    alacritty
    git htop
    gnupg zsh
    pcsclite
    pinentry-curses
    meslo-lg
    zsh
    zfs
    pkg-config
    openssl.dev
    openssl
    blueman
    gptfdisk
    keybase
    gnupg
    minikube
    iodine
    btrfs-progs
    linuxPackages.perf
  ];
  environment.pathsToLink = [ "/share/zsh" ];

  services.blueman.enable = true;
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: rec {
      neovim = pkgs.neovim.override {
        withNodeJs = true;
      };
    };
  };
  virtualisation.docker.enable = true;
  # virtualisation.libvirtd.enable = true;
  virtualisation.virtualbox.host.enable = false;
  virtualisation.virtualbox.host.enableExtensionPack  = true;
  programs.ssh.startAgent = false;
  services.pcscd.enable = true;
  services.udev.packages = with pkgs; [ yubikey-personalization ];
  services.fwupd.enable = true;
  services.printing.enable = true;
  services.keybase.enable = true;
  services.kbfs.enable = true;

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;
  services.openssh.extraConfig = "AllowUsers esk";

  networking.firewall.enable = false;
  networking.extraHosts = ''
    10.104.20.4 test-cert.euank.com.lan
  '';
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  services.xserver = {
    enable = true;
    layout = "us";
    desktopManager.gnome.enable = true;
    displayManager.defaultSession = "none+xmonad";
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages: [
        haskellPackages.xmonad-contrib haskellPackages.xmonad-extras haskellPackages.xmonad
      ];
    };
    libinput.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.esk = {
    isNormalUser = true;
    uid = 1000;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "docker" "libvirtd" "vboxusers" "wireshark" "dialout" "user-with-access-to-virtualbox" ];
  };

  security.pam.loginLimits = [{
    domain = "*";
    type = "soft";
    item = "nofile";
    value = "50000";
  }];

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.esk = import ./home.nix;

  nix = {
    trustedUsers = [ "root" "esk" ];
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
   };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}
