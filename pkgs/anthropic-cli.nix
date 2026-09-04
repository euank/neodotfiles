{ pkgs }:

pkgs.buildGoModule rec {
  pname = "anthropic-cli";
  version = "1.30.0";

  src = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "anthropic-cli";
    tag = "v${version}";
    hash = "sha256-O3J6w8xaFloLa4wp9K6w+XAMuk7zdmFeaJsKgo4I3f4=";
  };

  vendorHash = "sha256-FJqJOIaUMjOOpsROz68e2paY+Vig/anW0HxwaxjUC7c=";

  subPackages = [ "cmd/ant" ];

  meta = with pkgs.lib; {
    description = "Official CLI for the Claude Platform";
    homepage = "https://github.com/anthropics/anthropic-cli";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "ant";
  };
}
