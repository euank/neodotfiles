{ pkgs }:

let
  inherit (pkgs) fetchurl;
  deps = {
    imgui = fetchurl {
      url = "https://github.com/ocornut/imgui/archive/b916186e66aa3c02b72c6ca17455516512ed8049.tar.gz";
      sha256 = "a8e9ed7adb544e2d528722e96a229272716fb9e220a4b9e2ceee5469d548f562";
    };
    md4c = fetchurl {
      url = "https://github.com/mity/md4c/archive/refs/tags/v0.6.0.tar.gz";
      sha256 = "4d151298125a81da3b2efa2e0eed8bdb7a9318569804e4fa4d7a2375ab83ef70";
    };
    freetype = fetchurl {
      url = "https://download.savannah.gnu.org/releases/freetype/freetype-2.15.0.tar.xz";
      sha256 = "93cd47eb719c325107f2d3cf087d06299e944c3b48a40b55537302304dea1dd5";
    };
    sdl3 = fetchurl {
      url = "https://github.com/libsdl-org/SDL/releases/download/release-3.4.18/SDL3-3.4.18.tar.gz";
      sha256 = "9c75cf16330322c217dedd2e0609f1124f1b54b8633e763467b4684d0f4334a3";
    };
    mbedtls = fetchurl {
      url = "https://github.com/Mbed-TLS/mbedtls/releases/download/mbedtls-3.6.7/mbedtls-3.6.7.tar.bz2";
      sha256 = "a7e8bcbec0e6f761b4af24f25677626b35f762f68eef79c08677a363212d11f6";
    };
    cpp-httplib = fetchurl {
      url = "https://github.com/yhirose/cpp-httplib/archive/refs/tags/v0.43.0.tar.gz";
      sha256 = "28b88a7f0751c762cc9c70c91db0d6953554c40f49285907e716dd7943a824a5";
    };
    wuffs = fetchurl {
      url = "https://raw.githubusercontent.com/google/wuffs/v0.4.0-alpha.12/release/c/wuffs-v0.4.c";
      sha256 = "458066457347bd6d9bc3c906aa8292bea4488577727569ddd9436fdd89d5f04d";
    };
  };
in
pkgs.llvmPackages.stdenv.mkDerivation {
  pname = "prospero";
  version = "0.15.0-unstable-2026-11-07";

  src = pkgs.fetchFromGitHub {
    owner = "skeeto";
    repo = "prospero";
    rev = "541f1881647a416e492c7ad1cd58e1ea1a755509";
    sha256 = "01cjx9mg3c9sj7p4g7yvdpcj16hylhm7yqrb857gh1giimnl4f9c";
  };

  nativeBuildInputs = with pkgs; [
    cmake
    pkg-config
    wayland-scanner
    makeWrapper
  ];
  buildInputs = with pkgs; [
    libGL
    libdecor
    libxkbcommon
    wayland
    wayland-protocols
    libx11
    libxext
    libxcursor
    libxi
    libxrandr
    libxfixes
    libxrender
    libxscrnsaver
    libxtst
  ];

  postFixup = ''
    wrapProgram "$out/bin/prospero" --prefix LD_LIBRARY_PATH : ${
      pkgs.lib.makeLibraryPath (
        with pkgs;
        [
          libGL
          libxkbcommon
          wayland
          libx11
          libxext
          libxcursor
          libxi
          libxrandr
          libxfixes
          libxrender
          libxscrnsaver
          libxtst
          libdecor
          libei
          pipewire
        ]
      )
    }
  '';

  postUnpack = ''
    mkdir -p "$sourceRoot/deps"
    ${pkgs.lib.concatStringsSep "\n" (
      pkgs.lib.mapAttrsToList (
        name: source:
        if name == "wuffs" then
          ''
            mkdir -p "$sourceRoot/deps/wuffs"
            cp ${source} "$sourceRoot/deps/wuffs/wuffs-v0.4.c"
          ''
        else
          ''
            mkdir -p "$sourceRoot/deps/${name}"
            tar xf ${source} --strip-components=1 -C "$sourceRoot/deps/${name}"
          ''
      ) deps
    )}
  '';

  doCheck = true;
  installPhase = ''
    runHook preInstall
    cmake --install . --component prospero
    runHook postInstall
  '';

  meta = {
    description = "Agentic coding harness";
    homepage = "https://github.com/skeeto/prospero";
    license = pkgs.lib.licenses.unlicense;
    mainProgram = "prospero";
    platforms = pkgs.lib.platforms.linux;
  };
}
