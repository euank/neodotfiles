{ pkgs }:

let
  linear-unwrapped = pkgs.stdenv.mkDerivation rec {
    pname = "linear-cli-unwrapped";
    version = "3.0.0";

    src = pkgs.fetchurl {
      url = "https://github.com/schpet/linear-cli/releases/download/v${version}/linear-x86_64-unknown-linux-gnu.tar.xz";
      hash = "sha256-UGSmOn5qi1iTpVDhOMCnujc6rWXUJd3msrZrUKbBAok=";
    };

    sourceRoot = "linear-x86_64-unknown-linux-gnu";

    dontStrip = true;
    dontPatchELF = true;
    dontFixup = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp linear $out/bin/linear
      chmod +x $out/bin/linear
      runHook postInstall
    '';
  };
in
pkgs.buildFHSEnv {
  name = "linear";
  version = "3.0.0";

  targetPkgs = pkgs: [
    pkgs.stdenv.cc.cc.lib
  ];

  runScript = "${linear-unwrapped}/bin/linear";

  meta = with pkgs.lib; {
    description = "CLI for Linear issue tracking";
    homepage = "https://github.com/schpet/linear-cli";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "linear";
    platforms = [ "x86_64-linux" ];
  };
}
