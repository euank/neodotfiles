{ pkgs, inputs, ... }:

let
  inherit (inputs) home-manager nixos-hardware;
in
{
  imports = [
    ./hardware-configuration.nix
    home-manager.nixosModules.home-manager
    nixos-hardware.nixosModules.lenovo-thinkpad-x1-10th-gen
    ../shared/base.nix
    ../shared/desktop.nix
    "${inputs.ngrok-dev2}/nixos/client-module.nix"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  fileSystems."/".options = [
    "noatime"
    "nodiratime"
    "discard"
  ];

  hardware.enableRedistributableFirmware = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-531f03cf-7cf4-41ae-9238-aab6e6268d8b".device =
    "/dev/disk/by-uuid/531f03cf-7cf4-41ae-9238-aab6e6268d8b";
  boot.initrd.luks.devices."luks-531f03cf-7cf4-41ae-9238-aab6e6268d8b".keyFile =
    "/crypto_keyfile.bin";

  networking.hostName = "demerzel"; # Eto
  networking.hostId = "473650f2";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ja_JP.UTF-8";
    LC_IDENTIFICATION = "ja_JP.UTF-8";
    LC_MEASUREMENT = "ja_JP.UTF-8";
    LC_MONETARY = "ja_JP.UTF-8";
    LC_NAME = "ja_JP.UTF-8";
    LC_NUMERIC = "ja_JP.UTF-8";
    LC_PAPER = "ja_JP.UTF-8";
    LC_TELEPHONE = "ja_JP.UTF-8";
    LC_TIME = "ja_JP.UTF-8";
  };
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  # Thank you to https://discourse.nixos.org/t/networkd-iwd-upgrades-knock-machines-offline/38300/2
  networking.wireless.iwd = {
    enable = true;
    settings = {
      General = {
        # systemd-networkd renames ain interface for us
        UseDefaultInterface = true;
      };
    };
  };

  networking.networkmanager.unmanaged = [
    "wg0"
    "docker0"
    "br*"
  ];
  systemd.services.NetworkManager-wait-online.enable = false;
  networking.networkmanager.dhcp = "dhcpcd";
  networking.nameservers = [
    "8.8.8.8"
    "2001:4860:4860::8888"
  ];
  networking.dhcpcd.enable = false;

  #services.unifi = {
  #  enable = true;
  #  unifiPackage = pkgs.unifi7;
  #};

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  environment.systemPackages = with pkgs; [
    zfs
    keybase
    btrfs-progs
  ];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };
  # virtualisation.libvirtd.enable = true;
  virtualisation.virtualbox.host.enable = false;
  virtualisation.virtualbox.host.enableExtensionPack = true;

  services.bind.extraOptions = ''
    dnssec-validation no;
  '';
  services.fwupd.enable = true;
  services.printing.enable = true;
  services.keybase.enable = true;
  services.upower.enable = true;

  networking.firewall.enable = false;
  networking.firewall.trustedInterfaces = [ "wg0" ];
  networking.extraHosts = ''
    10.104.20.4 test-cert.euank.com.lan
    3.17.7.232 euankfoobar.ngrok.io
  '';

  home-manager.users.esk = import ./home.nix;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}
