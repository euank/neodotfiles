{
  final,
  inputs,
}:
let
  # httpx2 and httpcore2 are built from the same monorepo
  httpx2Version = "2.13.1";
  httpx2Src = final.fetchFromGitHub {
    owner = "pydantic";
    repo = "httpx2";
    tag = "v${httpx2Version}";
    hash = "sha256-XgjFiSwc4xCyPJcTB/Exh838fUOKsT0JRrha7s70C50=";
  };
  # nixpkgs has uv-dynamic-versioning 0.13; the version is bypassed in nix builds anyway
  relaxUvDynamicVersioning = ''
    substituteInPlace pyproject.toml --replace-fail '"uv-dynamic-versioning>=0.14.1"' '"uv-dynamic-versioning"'
  '';
in
pyFinal: pyPrev:
{
  # Needed by openai 3.x
  httpx2 = pyPrev.httpx2.overridePythonAttrs (old: {
    version = httpx2Version;
    src = httpx2Src;
    postPatch = old.postPatch + relaxUvDynamicVersioning;
  });
  httpcore2 = pyPrev.httpcore2.overridePythonAttrs (old: {
    version = httpx2Version;
    src = httpx2Src;
    postPatch = old.postPatch + relaxUvDynamicVersioning;
  });

  # Needed by openai 3.x
  jiter = pyPrev.jiter.overridePythonAttrs (old: rec {
    version = "0.17.0";
    src = final.fetchFromGitHub {
      owner = "pydantic";
      repo = "jiter";
      tag = "v${version}";
      hash = "sha256-ZYLxywATUWU/KmzVyBBsGIqGuWWyQoQHIOXPxHGkk9E=";
    };
    # Upstream now ships a Cargo.lock
    postPatch = "";
    cargoDeps = final.rustPlatform.fetchCargoVendor {
      inherit src;
      hash = "sha256-PeLwa+zvHGTQs8SyES3+W2+HFCEpGm4BJTm8LbdHGyg=";
    };
    meta = old.meta // {
      changelog = "https://github.com/pydantic/jiter/releases/tag/v${version}";
    };
  });

  # Needed by llm >= 0.33
  openai = pyPrev.openai.overridePythonAttrs (old: {
    version = "3.35.1";
    dependencies = map (d: if (d.pname or "") == "httpx" then pyFinal.httpx2 else d) old.dependencies;
    src = final.fetchFromGitHub {
      owner = "openai";
      repo = "openai-python";
      tag = "v3.35.1";
      hash = "sha256-qUXBgsChD2nBdlFDNzN2mD8UNpzosF+UBZeXLXzgOlA=";
    };
    postPatch = ''
      substituteInPlace pyproject.toml --replace-fail "hatchling==1.32.4" "hatchling"
    '';
    doCheck = false;
    meta = old.meta // {
      changelog = "https://github.com/openai/openai-python/releases/tag/v3.35.1";
    };
  });

  llm =
    (pyFinal.callPackage "${inputs.nixpkgs}/pkgs/development/python-modules/llm/default.nix" { })
    .overridePythonAttrs
      (old: {
        version = "0.36";
        src = final.fetchFromGitHub {
          owner = "simonw";
          repo = "llm";
          tag = "0.36";
          hash = "sha256-ocLMOoC0W0Ke5R9l69xiX6Xq/xOwTA0lV+Zo+03eFxg=";
        };
        # The nixpkgs embeddings-migration patches are already included in 0.36.
        patches = builtins.filter (
          p: final.lib.hasSuffix "001-disable-install-uninstall-commands.patch" (toString p)
        ) old.patches;
        doCheck = false;
        meta = old.meta // {
          changelog = "https://github.com/simonw/llm/releases/tag/0.36";
        };
      });

}
# llm >= 0.36 assigns tool_call_ids automatically, which these plugins' tests don't expect
//
  final.lib.genAttrs
    [
      "llm-echo"
      "llm-tools-datasette"
      "llm-tools-quickjs"
      "llm-tools-sqlite"
    ]
    (
      name:
      pyPrev.${name}.overridePythonAttrs (_: {
        doCheck = false;
      })
    )
// {
  anthropic = pyPrev.anthropic.overridePythonAttrs (old: {
    version = "1.15.0";
    src = final.fetchFromGitHub {
      owner = "anthropics";
      repo = "anthropic-sdk-python";
      tag = "v1.15.0";
      hash = "sha256-8GBcsm/O02QJOZ2dw5e1iMBg/SwqFnP1XL41+wH4lks=";
    };
    dependencies = old.dependencies ++ [ pyFinal.opentelemetry-api ];
    nativeCheckInputs = old.nativeCheckInputs ++ [ pyFinal.opentelemetry-sdk ];
    meta = old.meta // {
      changelog = "https://github.com/anthropics/anthropic-sdk-python/releases/tag/v1.15.0";
    };
  });

  llm-anthropic = pyPrev.llm-anthropic.overridePythonAttrs (_: {
    version = "0.30";
    doCheck = false;
    src = final.fetchurl {
      url = "https://files.pythonhosted.org/packages/source/l/llm-anthropic/llm_anthropic-0.30.tar.gz";
      hash = "sha256-QKP5T3bTk/AQHTqsZJAAlEOWtcjOTf1LNt9U5EGMY9A=";
    };
    dependencies = with pyFinal; [
      anthropic
      llm
    ];
  });
}
