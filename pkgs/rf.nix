{ pkgs }:

pkgs.buildGoModule {
  pname = "rf";
  version = "unstable-2026-07-10";

  src = pkgs.fetchFromGitHub {
    owner = "rsc";
    repo = "rf";
    rev = "85dbf8d53aee26328b0c0d0622d7a6e06f3e4af4";
    hash = "sha256-N/4/NDO+qEtY/pUYa9itDSO8dLL7WARNf7pljtAAGb8=";
  };

  vendorHash = "sha256-Hb7uPLdAXQxtljFNhqjAJOmXmjOIT8FlRxWBumDwylk=";

  # Expected error text differs with newer Go toolchains
  checkFlags = [ "-skip=TestRun/load_dep_error.txt" ];

  meta = with pkgs.lib; {
    description = "Refactoring tool for Go";
    homepage = "https://github.com/rsc/rf";
    license = licenses.bsd3;
    maintainers = [ ];
  };
}
