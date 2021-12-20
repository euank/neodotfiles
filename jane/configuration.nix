{ pkgs, inputs, ... }:

let
  authorizedKeys = [
	    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMdxqFTG7bPey17ZWg6LbonqASSNJnlmdMg3yiYPuNu6/b4Ffe4iycGAwVl/ODKnEzLZ2aWUhiVrLMv4Z6vml3/l/qU3PPeQRe+TY0afXLbT05xDG2HS/y5SE/6qoynKb2FzJ8YCpI3xdoJ3E4L5+a5vZ1yjknaFcHcL0/g5GCsKo0QpO6dH9Tz+W36Ua/kGXmqMzDaOraXLvTc2TBJ4Mm/CRy6zL773V4GE5e+w4MxdYGpaGZ2EaKw37xFAyx2lH2/RbRt+qTsvGOjfhXuMyOEtsrDEkM7mbRdjuC8WzlutTrDESRJuVAu47HEZjMKCaQ05wgI/LYS3CeolorGDf9tahnjS5s0x7X+NIRkEA0qgpxUwr5T9Z7JKWIIOV90Rbu6CFEfhldNtfA5uD8RLufIiiQTsTZmHjHaPWi98iphb+wMpy8yB4lPPzoWfSuofPVcWaLFoFzGwKkP38XLyeKXEyUgGJPTLPLkGNjQgTBqZlOTL06UR8GNKPtWo5dMCvsFuz0+u34LaeyNg+2i7gvhWZakDZ1EAqWdtj6A+8oAlIEa04OR09xlfdjA9BMA4xGyq9sOKn99tV5qTIZl3X+MIxxPUm0TYXulM4kByeKROAvQhgwSUJAE63qVddBnl+PAsUZPREl8l/ccuytZIlnDn2RY0LlIXGYb0tIEykSqw=="
	    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCyFcdo10FvG1lxiUKjccK2agmIIm13w0XmtftjI36q+7tg6ULrbFRdk/XITucTfSet/0y9Kup8QJM00i8k9EGD5SGcULhDX6p/mc0YTI1DeOHauAU3y7hlsE0a13sm5kg7XZ1dDqb5nY+8I6ZjHc5FlbjatAKHOSosljjIeOSvgg/tKJGf8qna4pzlgfhN4bf8jbK4ZJ6JoTVD9ulQqKKcwLdJFIxxKR4VxXVxGHiH8dvP3oPzhQ6W9GAc0yfBl8kIxJdzvEd5h7vX9b93ZFWolkkZYpyxbvapeeLmNX4e5TexWPUU1kT7jIi/rvTrSow5iYGu5rgwgqy6Ey37jhpQKQUgwkLPH1mt/9vg4WlpbPEk0TihDmW0yJ8CwHetZAs4cjSbiuMGopBf2rCEIrjyflKIiy/Of7MVp3NVEPVDOu3VEH/khxrHR5KC9XKOg4jhcsQBj0t+i1iJCmi981sXzXLHmmXZMNlcf0jFSG4TwApyc1+hJIBladsSZ12mLY1lFCTx/Yx3ztoNPqGPLAkNYuj3z50jL/Jdj2oVNcQqNpxb6bHmW416LcuUGQ9DSIJUJLxmv/CXW5Wpepm30KTumJSy6G6bBCe4b+Gw2g74K6uwjEaX2uGXNJvRNE+ftDf23fy1orO3HLncY23Du/R6iDcMj/coMMlkAES1AdxEFw=="
	    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyeivCOXMLvMzKvZjPzNSqD8kvkbsI/Ecdxe7V7HZDG8AfliS68frOZI5pl0uqfBet80e5qH/njDvdfKpKuBiAgUZcBz1+LGdrCr+Tn8Bi0ypu+xSpjJjPT0fVgD9qk0lv5TnUmqZD/BZShQjlp6T0MfETSbGppTxRRZIS2CgjO230fktZST8GUJBX/G0HVupqVdbORVdBkbEx4XfJLrmI3HSuA2drlImhCegrByg8r6k2Q/256myWri8Q2X0bVIg93FqcuLGvngGL8kJinwo/zRPo5ucfH0DWsQWtHo6ayx2FycMsCmd56ZU+FH9PBy73ki4ACqsaGh+T8silAR5R"
  ];
  secrets = inputs.secrets.jane;
in
{
  imports =
    [
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
      inputs.ngrok-dev.nixosModule
    ];
  nixpkgs.config.allowUnfree = true;
  services.ngrok-devenv = {
    enable = true;
    interfaces = {
      node = {
	create= false;
	name= "wg0";
	ipv4= "10.104.20.3";
      };
      mux = {
	create= false;
	name = "wg0";
	ipv4 = "10.104.20.4";
	ipv6 = "fe80::10:104:1:2";
      };
      tunnel = {
	create= false;
	name= "wg0";
	ipv4= "10.104.20.10";
	ipv6= "fe80::10:104:2:2";
      };
    };
  };
  services.redis.enable = true;

  services.bind = {
    forwarders = [ "8.8.8.8" "8.8.4.4" ];
  };

  networking.wireguard = {
    enable = true;
    interfaces = {
      wg0 = {
        ips = [ "10.104.20.0/25" ];
	privateKey = secrets.wireguard.privateKey;
	peers = [
	  {
	    allowedIPs = [ "10.104.0.0/16" ];
	    # Security by obscurity I guess, avoid publishing the endpoint too.
	    endpoint = secrets.wireguard.endpoint;
	    publicKey = "JjRwbg8GY8gQp0hWsNub6KsA7ptwjg/puZB1CVDiZjY=";
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
  boot.initrd.kernelModules = [ "e1000e" ];
  boot.initrd.luks.devices.root = {
    device = "/dev/disk/by-uuid/57065e03-da75-4174-a23b-a9af6e9ac59b";
    preLVM = true;
    allowDiscards = true;
  };
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      inherit authorizedKeys;
      port = 222;
      hostKeys = [ /etc/ssh/ssh_host_ed25519_key];
    };
    postCommands = ''
      echo 'cryptsetup-askpass' >> /root/.profile
    '';
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  boot.kernel.sysctl."fs.inotify.max_user_watches" = 99999;
  boot.kernel.sysctl."fs.inotify.max_user_instances" = 8192;

  virtualisation.docker.enable = true;
  networking.hostName = "jane"; # ender's game jane, or asimov's 'feminine intuition' jane, you pick

  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    curl vim git htop
    keybase
    alacritty
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.ports = [ 222 ];
  services.keybase.enable = true;
  services.kbfs.enable = true;

  networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [ 22 222 80 443 6443 ];
  networking.firewall.extraCommands = ''
    iptables -A INPUT -i wg0 -j ACCEPT
  '';

  users.users.esk = {
    isNormalUser = true;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = authorizedKeys;
    extraGroups = [ "wheel" "docker" "networkmanager" "docker" "libvirtd" "wireshark" ];
  };

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.esk = import ./home.nix;


  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}
