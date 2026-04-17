{
  pkgs,
  config,
  lib,
  ...
}:

{
  # disabledModules = [ "virtualisation/libvirtd.nix" ];
  imports = [
    ./hardware-configuration.nix
    ../shared/desktop.nix
  ];

  hardware.enableAllFirmware = true;
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="JP"
  '';
  boot.supportedFilesystems = [ "ntfs" ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  programs.fuse.userAllowOther = true;

  programs.steam = {
    enable = true;
    protontricks.enable = true;
  };

  services.usbmuxd.enable = true;
  environment.systemPackages = with pkgs; [
    libimobiledevice
    ifuse
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd = {
    kernelModules = [ "igb" ];
    network = {
      enable = true;
      udhcpc.enable = false;
      ssh = {
        enable = true;
        authorizedKeys = config.users.users.esk.openssh.authorizedKeys.keys;
        port = 222;
        hostKeys = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };
    };
    systemd = {
      network = {
        enable = true;
        networks."10-enp10s0" = {
          matchConfig.Name = "enp10s0";
          address = [ "192.168.2.2/24" ];
          routes = [
            {
              Destination = "192.168.2.1/32";
              Scope = "link";
            }
            {
              Gateway = "192.168.6.1";
              GatewayOnLink = true;
            }
          ];
        };
      };
      storePaths = [ (lib.getExe' config.boot.initrd.systemd.package "systemd-tty-ask-password-agent") ];
      services.initrd-ssh-unlock-profile = {
        description = "Set initrd SSH login profile for disk unlock";
        wantedBy = [ "initrd.target" ];
        before = [ "sshd.service" ];
        unitConfig.DefaultDependencies = false;
        serviceConfig.Type = "oneshot";
        script = ''
          echo '${lib.getExe' config.boot.initrd.systemd.package "systemd-tty-ask-password-agent"} --watch' >> /root/.profile
        '';
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
      # systemd-networkd renames interfaces for us
      DriverQuirks.UseDefaultInterface = true;
      General = {
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

  networking.wireguard.interfaces = {
    ygg0 = {
      ips = [ "10.104.6.1" ];
      privateKeyFile = "/etc/wg/key";
      peers = [
        {
          allowedIPs = [ "10.104.0.0/16" ];
          endpoint = "home.euank.com:64512";
          publicKey = "+pLrsgXAn4rH4e+gQWR03n02o2vDNiL1sDOXEYSrmGg=";
          persistentKeepalive = 25;
        }
      ];
    };
  };
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

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.useDHCP = false;
  networking.interfaces.enp10s0.useDHCP = true;
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
