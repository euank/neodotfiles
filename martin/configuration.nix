{ pkgs, inputs, ... }:

let
  inherit (inputs) home-manager;
in
{
  imports = [
    ./hardware-configuration.nix
    home-manager.nixosModules.home-manager
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen
    ../shared/base.nix
    ../shared/desktop.nix
  ];

  fileSystems."/".options = ["noatime" "nodiratime" "discard" ];

  hardware.enableRedistributableFirmware = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/e5624a65-5c32-4761-847a-8deda806714c";
      preLVM = true;
      allowDiscards = true;
    };
  };

  networking.hostName = "martin";
  networking.hostId = "473650f9";
  networking.networkmanager.enable = true;
  networking.networkmanager.unmanaged = [ "wg0" "docker0" "br*" ];
  systemd.services.NetworkManager-wait-online.enable = false;
  networking.networkmanager.dhcp = "dhcpcd";
  networking.nameservers = [ "8.8.8.8" "2001:4860:4860::8888" ];
  networking.dhcpcd.enable = false;

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  environment.systemPackages = with pkgs; [
    zfs
    keybase
    btrfs-progs
  ];

  virtualisation.docker.enable = true;
  # virtualisation.libvirtd.enable = true;
  virtualisation.virtualbox.host.enable = false;
  virtualisation.virtualbox.host.enableExtensionPack  = true;

  services.bind.extraOptions = ''
    dnssec-validation no;
  '';
  services.fwupd.enable = true;
  services.printing.enable = true;
  services.keybase.enable = true;
  services.kbfs.enable = true;
  services.upower.enable = true;

  networking.firewall.enable = false;
  home-manager.users.esk = import ./home.nix;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}
