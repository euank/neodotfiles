{
  pkgs,
  inputs,
  config,
  ...
}:

let
  inherit (inputs) home-manager;
in
{
  # disabledModules = [ "virtualisation/libvirtd.nix" ];
  imports = [
    ./hardware-configuration.nix
    ../shared/desktop.nix
  ];

  hardware.enableAllFirmware = true;

  programs.steam = {
    enable = true;
    protontricks.enable = true;
  };

  # boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  # boot.kernelPackages = pkgs.linuxPackages;
  boot.kernelPackages = pkgs.linuxPackages_testing;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd = {
    kernelModules = [ "igb" ];
    network = {
      enable = true;
      udhcpc.enable = false;
      postCommands = ''
        ip address add 192.168.2.2/24 brd + dev enp8s0
        ip route add 192.168.2.1 dev enp8s0
        ip route add default via 192.168.6.1 dev enp8s0
        ip a

        echo 'cryptsetup-askpass' >> /root/.profile
      '';
      ssh = {
        enable = true;
        authorizedKeys = config.users.users.esk.openssh.authorizedKeys.keys;
        port = 222;
        hostKeys = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };
    };
  };

  services.fstrim.enable = true;
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
    virtualHosts."dev.lan" = {
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

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  # Thank you to https://discourse.nixos.org/t/networkd-iwd-upgrades-knock-machines-offline/38300/2
  networking.wireless.iwd = {
    enable = true;
    settings = {
      General = {
        # systemd-networkd renames interfaces for us
        UseDefaultInterface = true;
        # Needed for some reason
        ControlPortOverNL80211 = false;
      };
    };
  };

  # networking.networkmanager.dhcp = "dhcpcd";
  networking.nameservers = [
    "8.8.8.8"
    "2001:4860:4860::8888"
  ];
  # networkmanager already handles this
  networking.dhcpcd.enable = false;

  # Ceph
  services.ceph = {
    enable = false;
    global = {
      fsid = "fc99899d-6144-4288-be8f-d8dd4adbae00";
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
      daemons = [
        "osdb3f"
        "osd36a"
        "osd9f4"
      ];
    };
  };

  #networking.wireguard.interfaces = {
  #  wgfly0 = {
  #    ips = [ "fdaa:0:2e37:a7b:907b:0:a:2/120" ];
  #    privateKeyFile = "/etc/wg/fly-wg";
  #    peers = [
  #      {
  #        publicKey = "GM0QhyCeUTh/BeFQtxcDDAqSycM31hie6ucXX/EhbC4=";
  #        allowedIPs = [ "fdaa:0:2e37::/48" ];
  #        endpoint = "sea2.gateway.6pn.dev:51820";
  #        persistentKeepalive = 15;
  #      }
  #    ];
  #  };
  #};

  # As in the the ttgl mecha
  networking.hostName = "Enkidudu";
  networking.hostId = "373650f1";

  programs.adb.enable = true;
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.useDHCP = false;
  networking.interfaces.enp8s0.useDHCP = true;
  networking.firewall.enable = false;

  services.xserver.videoDrivers = [ "amdgpu" ];
  fonts.fontDir.enable = true;

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };

  virtualisation.virtualbox.host.enable = false;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  virtualisation.libvirtd.enable = false;

  home-manager.users.esk = import ./home.nix;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}
