{ pkgs, inputs, config, ... }:

let
  inherit (inputs) home-manager;
in
{
  # disabledModules = [ "virtualisation/libvirtd.nix" ];
  imports = [
    ./hardware-configuration.nix
    ../shared/base.nix
    ../shared/desktop.nix
    home-manager.nixosModules.home-manager
  ];

  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];

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

  # Ceph
  services.ceph = {
    enable = true;
    global = {
      fsid = "97b365e0-2373-4505-8428-7f8a6d2ba76f";
      clusterName = "ptank";
      monHost = "127.0.0.1";
      monInitialMembers = "enkidudu";
    };
    mon = {
      enable = true;
      daemons = [ "enkidudu" ];
    };
    mgr = {
      enable = true;
      daemons = [ "enkidudu" ];
    };
    osd = {
      enable = true;
      daemons = [ "osdb3f" "osd36a" "osd9f4" ];
    };
  };


  # As in the the ttgl mecha
  networking.hostName = "Enkidudu";
  networking.hostId = "373650f1";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  programs.adb.enable = true;
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.useDHCP = false;
  networking.interfaces.enp8s0.useDHCP = true;
  networking.interfaces.wlp6s0.useDHCP = false;
  networking.firewall.enable = false;

  # x11
  services.xserver.videoDrivers = [ "amdgpu" ];
  # services.xserver.xrandrHeads = [
  #   "DisplayPort-1"
  #   "DisplayPort-0"
  # ];

  virtualisation.docker.enable = true;

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  virtualisation.libvirtd.enable = true;

  home-manager.users.esk = import ./home.nix;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}
