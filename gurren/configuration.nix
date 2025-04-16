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
    ../shared/desktop.nix
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

  hardware.enableAllFirmware = true;
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="JP"
  '';
  # drop internal bluetooth, use a usb dongle. The internal one doesn't work w/
  # my headset.
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0489", ATTRS{idProduct}=="e10a", ATTR{authorized}="0"
  '';

  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_testing.override {
  #   argsOverride = {
  #     src = pkgs.fetchFromGitHub {
  #       owner = "euank";
  #       repo = "linux";
  #       rev = "15ecf4de9dc36e2dd798335c929094ddbcf034cb"; # 6.15-rc2-ath12k
  #       sha256 = "sha256-LoH3mVqhMQU+PYo/Wn138BoQhKyitekbYZi3q5W4RQ0=";
  #     };
  #     ignoreConfigErrors = true;
  #     version = "6.15.0-rc2";
  #     modDirVersion = "6.15.0-rc2";
  #     extraConfig = ''
  #       CONFIG_EXPERT y
  #       CONFIG_CFG80211_CERTIFICATION_ONUS y
  #       CONFIG_ATH_REG_DYNAMIC_USER_REG_HINTS y
  #     '';
  #   };
  # });

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.fstrim.enable = true;

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

  # As in the the ttgl mecha
  networking.hostName = "gurren";
  networking.hostId = "356950f1";

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.useDHCP = false;

  services.xserver.videoDrivers = [ "amdgpu" ];
  fonts.fontDir.enable = true;

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };

  virtualisation.virtualbox.host.enable = false;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  virtualisation.libvirtd.enable = false;

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
