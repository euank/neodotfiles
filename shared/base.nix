{ pkgs, inputs, ... }:

# Bits of configuration I want as the default on all my machines
{
  imports = [
    # inputs.dwarffs.nixosModules.dwarffs
    inputs.home-manager.nixosModules.home-manager
  ];

  boot.kernel.sysctl."fs.inotify.max_user_watches" = 99999;
  boot.kernel.sysctl."fs.inotify.max_user_instances" = 8192;

  environment.systemPackages = with pkgs; [
    curl
    git
    gnupg
    htop
    linuxPackages.perf
    neovim
    openssl
    pinentry-curses
    pkg-config
    vim
    wget
    zsh
  ];
  environment.pathsToLink = [ "/share/zsh" ];
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    extraConfig = "AllowUsers esk";
  };

  programs.zsh.enable = true;

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  users.users.esk = {
    isNormalUser = true;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyeivCOXMLvMzKvZjPzNSqD8kvkbsI/Ecdxe7V7HZDG8AfliS68frOZI5pl0uqfBet80e5qH/njDvdfKpKuBiAgUZcBz1+LGdrCr+Tn8Bi0ypu+xSpjJjPT0fVgD9qk0lv5TnUmqZD/BZShQjlp6T0MfETSbGppTxRRZIS2CgjO230fktZST8GUJBX/G0HVupqVdbORVdBkbEx4XfJLrmI3HSuA2drlImhCegrByg8r6k2Q/256myWri8Q2X0bVIg93FqcuLGvngGL8kJinwo/zRPo5ucfH0DWsQWtHo6ayx2FycMsCmd56ZU+FH9PBy73ki4ACqsaGh+T8silAR5R"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMdxqFTG7bPey17ZWg6LbonqASSNJnlmdMg3yiYPuNu6/b4Ffe4iycGAwVl/ODKnEzLZ2aWUhiVrLMv4Z6vml3/l/qU3PPeQRe+TY0afXLbT05xDG2HS/y5SE/6qoynKb2FzJ8YCpI3xdoJ3E4L5+a5vZ1yjknaFcHcL0/g5GCsKo0QpO6dH9Tz+W36Ua/kGXmqMzDaOraXLvTc2TBJ4Mm/CRy6zL773V4GE5e+w4MxdYGpaGZ2EaKw37xFAyx2lH2/RbRt+qTsvGOjfhXuMyOEtsrDEkM7mbRdjuC8WzlutTrDESRJuVAu47HEZjMKCaQ05wgI/LYS3CeolorGDf9tahnjS5s0x7X+NIRkEA0qgpxUwr5T9Z7JKWIIOV90Rbu6CFEfhldNtfA5uD8RLufIiiQTsTZmHjHaPWi98iphb+wMpy8yB4lPPzoWfSuofPVcWaLFoFzGwKkP38XLyeKXEyUgGJPTLPLkGNjQgTBqZlOTL06UR8GNKPtWo5dMCvsFuz0+u34LaeyNg+2i7gvhWZakDZ1EAqWdtj6A+8oAlIEa04OR09xlfdjA9BMA4xGyq9sOKn99tV5qTIZl3X+MIxxPUm0TYXulM4kByeKROAvQhgwSUJAE63qVddBnl+PAsUZPREl8l/ccuytZIlnDn2RY0LlIXGYb0tIEykSqw=="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCyFcdo10FvG1lxiUKjccK2agmIIm13w0XmtftjI36q+7tg6ULrbFRdk/XITucTfSet/0y9Kup8QJM00i8k9EGD5SGcULhDX6p/mc0YTI1DeOHauAU3y7hlsE0a13sm5kg7XZ1dDqb5nY+8I6ZjHc5FlbjatAKHOSosljjIeOSvgg/tKJGf8qna4pzlgfhN4bf8jbK4ZJ6JoTVD9ulQqKKcwLdJFIxxKR4VxXVxGHiH8dvP3oPzhQ6W9GAc0yfBl8kIxJdzvEd5h7vX9b93ZFWolkkZYpyxbvapeeLmNX4e5TexWPUU1kT7jIi/rvTrSow5iYGu5rgwgqy6Ey37jhpQKQUgwkLPH1mt/9vg4WlpbPEk0TihDmW0yJ8CwHetZAs4cjSbiuMGopBf2rCEIrjyflKIiy/Of7MVp3NVEPVDOu3VEH/khxrHR5KC9XKOg4jhcsQBj0t+i1iJCmi981sXzXLHmmXZMNlcf0jFSG4TwApyc1+hJIBladsSZ12mLY1lFCTx/Yx3ztoNPqGPLAkNYuj3z50jL/Jdj2oVNcQqNpxb6bHmW416LcuUGQ9DSIJUJLxmv/CXW5Wpepm30KTumJSy6G6bBCe4b+Gw2g74K6uwjEaX2uGXNJvRNE+ftDf23fy1orO3HLncY23Du/R6iDcMj/coMMlkAES1AdxEFw=="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCKqFuQdr7H2xwTM1p/CEbFvZ7oVPX1fjwYkJOv50O70a+NXaAs9Eg5Cnyhs0pKLwogMp3AZsdkVPyUtZIuShFw/e7DAz6Eo4kdXoU8oMhYqWEAFfTF+m/uCWoesPQK+6XQute7DkqR+0A+tgc7dNM9TYZyXdNNl/corxchGH+K0S+ENdcM8j4qllBxJE6GtlFQgMzN3URW2g6lTTGD8HoICl+ajfuLGBsg7O8UZHM9qsLC0K4Ej23FF9GIMEYlnSentVZo4o1hj/xTzsiKhl1EFvP8oo22vYkebQRX0XhrNCehouQYrmM0fSS7+m9UjQK9jWaXBZ+Z5r/ppoJzQ80p"
    ];
    extraGroups = [
      "docker"
      "dwarffs"
      "libvirtd"
      "networkmanager"
      "user-with-access-to-virtualbox"
      "video"
      "wheel"
      "wireshark"
      "adbusers"
    ];
  };

  security.pam.loginLimits = [{
    domain = "*";
    type = "soft";
    item = "nofile";
    value = "50000";
  }];
  security.pam.services.swaylock = {};

  nix = {
    settings = {
      trusted-users = [ "root" "esk" ];
      experimental-features = "nix-command flakes recursive-nix dynamic-derivations ca-derivations";
    };
   };
}
