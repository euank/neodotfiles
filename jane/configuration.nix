{
  pkgs,
  inputs,
  config,
  ...
}:

let
  secrets = inputs.secrets.jane;
in
{
  imports = [
    ./hardware-configuration.nix
    ../shared/base.nix
    inputs.ngrok-dev.nixosModules.default
  ];
  services.ngrok-devenv = {
    enable = true;
    useNixBinaryCache = true;
    userHome = "/home/esk";
    repoRoot = "/home/esk/dev/ngrok";
    interfaces = {
      node = {
        create = false;
        name = "wg0";
        ipv4 = "10.104.20.3";
      };
      dataplanes = {
        us = {
          mux = {
            create = false;
            name = "wg0";
            ipv4 = "10.104.20.4";
            ipv6 = "fe80::10:104:1:2";
          };
          tunnel = {
            create = false;
            name = "wg0";
            ipv4 = "10.104.20.10";
            ipv6 = "fe80::10:104:2:2";
          };
        };
        l2 = {
          mux = {
            create = false;
            name = "wg0";
            ipv4 = "10.104.20.5";
            ipv6 = "fe80::10:104:1:3";
          };
          tunnel = {
            create = false;
            name = "wg0";
            ipv4 = "10.104.20.11";
            ipv6 = "fe80::10:104:2:3";
          };
        };
      };
    };
  };

  services.bind = {
    forwarders = [
      "8.8.8.8"
      "8.8.4.4"
    ];
  };

  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;
  networking.networkmanager.dhcp = "dhcpcd";
  networking.dhcpcd.enable = false;

  networking.wireguard = {
    enable = true;
    interfaces = {
      wg0 = {
        # ipip tunnel + wg
        mtu = 1380;
        ips = [ "10.104.20.0/25" ];
        privateKey = secrets.wireguard.privateKey;
        peers = [
          {
            allowedIPs = [ "10.104.0.0/16" ];
            # Security by obscurity I guess, avoid publishing the endpoint too.
            endpoint = secrets.wireguard.endpoint;
            publicKey = "+pLrsgXAn4rH4e+gQWR03n02o2vDNiL1sDOXEYSrmGg=";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };

  services.nfs.server = {
    enable = false;
    exports = ''
      /home/esk/dev/ngrok 192.168.121.1(rw,fsid=0,no_subtree_check)
    '';
  };
  virtualisation.libvirtd.enable = false;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [
    "e1000e"
    "igb"
    "iwlwifi"
  ];
  boot.initrd.luks.devices.root = {
    device = "/dev/disk/by-uuid/f7d876d1-549f-4b6a-ac1e-094c5eb8ec87";
    preLVM = true;
    allowDiscards = true;
  };
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      authorizedKeys = config.users.users.esk.openssh.authorizedKeys.keys;
      port = 222;
      hostKeys = [ /etc/ssh/ssh_host_ed25519_key ];
    };
    postCommands = ''
      echo 'cryptsetup-askpass' >> /root/.profile
    '';
  };
  boot.kernelPackages = pkgs.linuxPackages;
  fileSystems."/".options = [
    "noatime"
    "nodiratime"
    "discard"
  ];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };
  networking.hostName = "jane"; # ender's game jane, or asimov's 'feminine intuition' jane, you pick

  networking.interfaces.eno1.useDHCP = true;
  # networking.interfaces.wlp0s20f3.useDHCP = false;

  environment.systemPackages = with pkgs; [
    keybase
    alacritty
  ];

  # just to make sure we don't reboot into an unworking mess. As I've had happen before on an otherwise rote kernel update.
  hardware.enableAllFirmware = true;

  # Enable the OpenSSH daemon.
  services.openssh.ports = [ 222 ];

  networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [
    22
    222
    80
    443
    6443
    8080
    9090
  ];
  networking.firewall.extraCommands = ''
    iptables -A INPUT -i wg0 -j ACCEPT
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
