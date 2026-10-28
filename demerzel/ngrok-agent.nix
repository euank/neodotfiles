{ lib, ... }:

let
  # TODO: nix package
  ngrokBin = "/usr/local/libexec/ngrok/ngrok";
in
{
  users.users.ngrok = {
    isSystemUser = true;
    group = "ngrok";
  };
  users.groups.ngrok = { };
  systemd.tmpfiles.rules = [
    "d /etc/ngrok 0700 ngrok ngrok -"
    "d /var/lib/ngrok-agent 0755 ngrok ngrok -"
    "f /var/lib/ngrok-agent/daemon.log 0600 ngrok ngrok -"
  ];
  systemd.services.ngrok-agent = {
    description = "ngrok agent";
    documentation = [ "https://ngrok.com/docs" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = lib.escapeShellArgs [
        ngrokBin
        "agent"
        "serve"
        "--agent-config"
        "/etc/ngrok/agent.yml"
        "--state-file"
        "/var/lib/ngrok-agent/agent.db"
        "--log-file"
        "/var/lib/ngrok-agent/daemon.log"
        "--socket"
        "/var/run/ngrok-agent/agent.sock"
        "--managed"
        "system"
      ];
      User = "ngrok";
      Group = "ngrok";
      Restart = "always";
      RestartSec = 5;
      RestartPreventExitStatus = 86;
      SuccessExitStatus = 86;
      LimitNOFILE = 65536;
      RuntimeDirectory = "ngrok-agent";
      StateDirectory = "ngrok-agent";
      StandardOutput = "append:/var/lib/ngrok-agent/daemon.log";
      StandardError = "append:/var/lib/ngrok-agent/daemon.log";
      # Private-endpoint (TUN) routing.
      AmbientCapabilities = [ "CAP_NET_ADMIN" ];
      CapabilityBoundingSet = [ "CAP_NET_ADMIN" ];
    };
  };
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.user != "ngrok") {
        return polkit.Result.NOT_HANDLED;
      }
      switch (action.id) {
        case "org.freedesktop.resolve1.set-dns-servers":
        case "org.freedesktop.resolve1.set-domains":
        case "org.freedesktop.resolve1.revert":
          return polkit.Result.YES;
      }
      return polkit.Result.NOT_HANDLED;
    });
  '';
}
