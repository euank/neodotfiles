{ pkgs }:

pkgs.buildGoModule rec {
  pname = "anthropic-cli";
  version = "1.42.0";

  src = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "anthropic-cli";
    tag = "v${version}";
    hash = "sha256-WS6pub4Gc9QhNnRNNPD/ORYmaVrBEtKt4Hd5Iv4iI34=";
  };

  vendorHash = "sha256-PMN+BrUxURQKYKdHzOe/iLAoxZ9+RmoOkKsD4X8LmGc=";

  subPackages = [ "cmd/ant" ];

  meta = with pkgs.lib; {
    description = "Official CLI for the Claude Platform";
    homepage = "https://github.com/anthropics/anthropic-cli";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "ant";
  };
}
