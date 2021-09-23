{ pkgs, inputs, ... }:

let
  inherit (inputs) home-manager dwarffs;
in
{
  # disabledModules = [ "virtualisation/libvirtd.nix" ];
  imports = [
    ./hardware-configuration.nix
    home-manager.nixosModules.home-manager
    dwarffs.nixosModules.dwarffs
  ];

  # (;_;)
  nixpkgs.config.allowUnfree = true;

  boot.kernel.sysctl."fs.inotify.max_user_instances" = 8192;
  # Latest supported kernel with zfs support
  boot.kernelPackages = pkgs.linuxPackages_5_13;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];

  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  hardware.pulseaudio.support32Bit = true;


  # services.spigot-mc = {
  #       enable = false;
  #       # openFirewall = true;
  #       eula = true;
  #       # declarative = true;
  #       package = nixek.spigot-mc;
  #       plugins = [ nixek.bukkit-plugins.sudofeedme nixek.bukkit-plugins.discordsrv ];
  #       dataDir = "/var/lib/minecraft";
  #       jvmOpts = "-Xmx1096M -Xms1048M";
  #       serverProperties = {
  #         motd = "Testing server";
  #         pvp = false;
  #       };
  # };

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
    curl wget vim neovim
    dmenu alacritty
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
    # vivarium
  ];
  environment.pathsToLink = [ "/share/zsh" ];
  services.openssh.enable = true;

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
  users.users.esk = {
    isNormalUser = true;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyeivCOXMLvMzKvZjPzNSqD8kvkbsI/Ecdxe7V7HZDG8AfliS68frOZI5pl0uqfBet80e5qH/njDvdfKpKuBiAgUZcBz1+LGdrCr+Tn8Bi0ypu+xSpjJjPT0fVgD9qk0lv5TnUmqZD/BZShQjlp6T0MfETSbGppTxRRZIS2CgjO230fktZST8GUJBX/G0HVupqVdbORVdBkbEx4XfJLrmI3HSuA2drlImhCegrByg8r6k2Q/256myWri8Q2X0bVIg93FqcuLGvngGL8kJinwo/zRPo5ucfH0DWsQWtHo6ayx2FycMsCmd56ZU+FH9PBy73ki4ACqsaGh+T8silAR5R"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMdxqFTG7bPey17ZWg6LbonqASSNJnlmdMg3yiYPuNu6/b4Ffe4iycGAwVl/ODKnEzLZ2aWUhiVrLMv4Z6vml3/l/qU3PPeQRe+TY0afXLbT05xDG2HS/y5SE/6qoynKb2FzJ8YCpI3xdoJ3E4L5+a5vZ1yjknaFcHcL0/g5GCsKo0QpO6dH9Tz+W36Ua/kGXmqMzDaOraXLvTc2TBJ4Mm/CRy6zL773V4GE5e+w4MxdYGpaGZ2EaKw37xFAyx2lH2/RbRt+qTsvGOjfhXuMyOEtsrDEkM7mbRdjuC8WzlutTrDESRJuVAu47HEZjMKCaQ05wgI/LYS3CeolorGDf9tahnjS5s0x7X+NIRkEA0qgpxUwr5T9Z7JKWIIOV90Rbu6CFEfhldNtfA5uD8RLufIiiQTsTZmHjHaPWi98iphb+wMpy8yB4lPPzoWfSuofPVcWaLFoFzGwKkP38XLyeKXEyUgGJPTLPLkGNjQgTBqZlOTL06UR8GNKPtWo5dMCvsFuz0+u34LaeyNg+2i7gvhWZakDZ1EAqWdtj6A+8oAlIEa04OR09xlfdjA9BMA4xGyq9sOKn99tV5qTIZl3X+MIxxPUm0TYXulM4kByeKROAvQhgwSUJAE63qVddBnl+PAsUZPREl8l/ccuytZIlnDn2RY0LlIXGYb0tIEykSqw=="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCyFcdo10FvG1lxiUKjccK2agmIIm13w0XmtftjI36q+7tg6ULrbFRdk/XITucTfSet/0y9Kup8QJM00i8k9EGD5SGcULhDX6p/mc0YTI1DeOHauAU3y7hlsE0a13sm5kg7XZ1dDqb5nY+8I6ZjHc5FlbjatAKHOSosljjIeOSvgg/tKJGf8qna4pzlgfhN4bf8jbK4ZJ6JoTVD9ulQqKKcwLdJFIxxKR4VxXVxGHiH8dvP3oPzhQ6W9GAc0yfBl8kIxJdzvEd5h7vX9b93ZFWolkkZYpyxbvapeeLmNX4e5TexWPUU1kT7jIi/rvTrSow5iYGu5rgwgqy6Ey37jhpQKQUgwkLPH1mt/9vg4WlpbPEk0TihDmW0yJ8CwHetZAs4cjSbiuMGopBf2rCEIrjyflKIiy/Of7MVp3NVEPVDOu3VEH/khxrHR5KC9XKOg4jhcsQBj0t+i1iJCmi981sXzXLHmmXZMNlcf0jFSG4TwApyc1+hJIBladsSZ12mLY1lFCTx/Yx3ztoNPqGPLAkNYuj3z50jL/Jdj2oVNcQqNpxb6bHmW416LcuUGQ9DSIJUJLxmv/CXW5Wpepm30KTumJSy6G6bBCe4b+Gw2g74K6uwjEaX2uGXNJvRNE+ftDf23fy1orO3HLncY23Du/R6iDcMj/coMMlkAES1AdxEFw=="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCKqFuQdr7H2xwTM1p/CEbFvZ7oVPX1fjwYkJOv50O70a+NXaAs9Eg5Cnyhs0pKLwogMp3AZsdkVPyUtZIuShFw/e7DAz6Eo4kdXoU8oMhYqWEAFfTF+m/uCWoesPQK+6XQute7DkqR+0A+tgc7dNM9TYZyXdNNl/corxchGH+K0S+ENdcM8j4qllBxJE6GtlFQgMzN3URW2g6lTTGD8HoICl+ajfuLGBsg7O8UZHM9qsLC0K4Ej23FF9GIMEYlnSentVZo4o1hj/xTzsiKhl1EFvP8oo22vYkebQRX0XhrNCehouQYrmM0fSS7+m9UjQK9jWaXBZ+Z5r/ppoJzQ80p"
    ];
    extraGroups = [ "wheel" "docker" "adbusers" "user-with-access-to-virtualbox" "libvirtd" "video" "dwarffs" ];
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
