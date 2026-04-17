{
  pkgs,
  inputs,
  config,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../shared/desktop.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/1bc449c3-9399-4710-ad8a-bc21d8e12864";
      preLVM = true;
      allowDiscards = true;
    };
  };
  boot.initrd.network = {
    enable = false;
    ssh = {
      enable = true;
      authorizedKeys = config.users.users.esk.openssh.authorizedKeys.keys;
      port = 222;
      hostKeys = [ /etc/ssh/ssh_host_ed25519_key ];
    };
  };
  boot.initrd.systemd = {
    storePaths = [ "${config.boot.initrd.systemd.package}/bin/systemd-tty-ask-password-agent" ];
    services.initrd-ssh-unlock-profile = {
      description = "Set initrd SSH login profile for disk unlock";
      wantedBy = [ "initrd.target" ];
      before = [ "sshd.service" ];
      unitConfig.DefaultDependencies = false;
      serviceConfig.Type = "oneshot";
      script = ''
        echo '${config.boot.initrd.systemd.package}/bin/systemd-tty-ask-password-agent --watch' >> /root/.profile
      '';
    };
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;
  fileSystems."/".options = [
    "noatime"
    "nodiratime"
    "discard"
  ];
  networking.hostName = "pascal";

  networking.useDHCP = false;
  networking.interfaces.enp2s0f0.useDHCP = true;

  environment.systemPackages = with pkgs; [
    vim
    alacritty
  ];

  hardware.enableAllFirmware = true;

  # Enable the OpenSSH daemon.
  services.openssh.ports = [ 222 ];
  services.keybase.enable = true;
  services.kbfs.enable = true;

  networking.firewall.enable = false;
  home-manager.users.esk = import ./home.nix;

  system.stateVersion = "20.03";
}
