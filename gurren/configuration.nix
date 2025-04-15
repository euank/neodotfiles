{
  pkgs,
  config,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../shared/desktop.nix
  ];

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
