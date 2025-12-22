{ pkgs }:

pkgs.buildGoModule {
  pname = "rf";
  version = "unstable-2024-12-22";

  src = pkgs.fetchFromGitHub {
    owner = "rsc";
    repo = "rf";
    rev = "cc8efa1df9a0aaf14896212f14d07f01e944e2f1";
    hash = "sha256-maD3dLXd2DEsD75e6jBNJEDzJlCe58zkHC//TG/ZF60=";
  };

  vendorHash = "sha256-Hb7uPLdAXQxtljFNhqjAJOmXmjOIT8FlRxWBumDwylk=";

  meta = with pkgs.lib; {
    description = "Refactoring tool for Go";
    homepage = "https://github.com/rsc/rf";
    license = licenses.bsd3;
    maintainers = [ ];
  };
}
