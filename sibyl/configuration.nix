{
  pkgs,
  config,
  inputs,
  ...
}:

let
  secrets = inputs.secrets.gurren;
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
        ipv4 = "10.104.21.3";
      };
      dataplanes = {
        us = {
          mux = {
            create = false;
            name = "wg0";
            ipv4 = "10.104.21.4";
            ipv6 = "fe80::10:104:11:2";
          };
          tunnel = {
            create = false;
            name = "wg0";
            ipv4 = "10.104.21.10";
            ipv6 = "fe80::10:104:21:2";
          };
        };
        l2 = {
          mux = {
            create = false;
            name = "wg0";
            ipv4 = "10.104.21.5";
            ipv6 = "fe80::10:104:11:3";
          };
          tunnel = {
            create = false;
            name = "wg0";
            ipv4 = "10.104.21.11";
            ipv6 = "fe80::10:104:21:3";
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

  networking.interfaces.eno1.wakeOnLan.enable = true;

  networking.wireguard = {
    enable = true;
    interfaces = {
      wg0 = {
        # ipip tunnel + wg
        mtu = 1380;
        ips = [ "10.104.21.0/25" ];
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

  hardware.enableAllFirmware = true;
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="JP"
  '';
  boot.extraModulePackages = with config.boot.kernelPackages; [
    r8125
  ];
  boot.initrd.kernelModules = [ "r8125" ];

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

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.fstrim.enable = true;

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  # Thank you to https://discourse.nixos.org/t/networkd-iwd-upgrades-knock-machines-offline/38300/2
  networking.wireless.iwd = {
    enable = true;
  };

  i18n.defaultLocale = "en_US.UTF-8";
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

  # networking.networkmanager.dhcp = "dhcpcd";
  networking.nameservers = [
    "8.8.8.8"
    "2001:4860:4860::8888"
  ];
  # networkmanager already handles this
  networking.dhcpcd.enable = false;

  # As in the the ttgl mecha
  networking.hostName = "sibyl";
  networking.hostId = "356950f2";

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.useDHCP = false;

  services.xserver.videoDrivers = [ "amdgpu" ];
  fonts.fontDir.enable = true;

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };

  environment.systemPackages = with pkgs; [
    keybase
    alacritty
  ];
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
