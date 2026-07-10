{
  final,
  inputs,
}:
pyFinal: pyPrev: {
  llm =
    (pyFinal.callPackage "${inputs.nixpkgs}/pkgs/development/python-modules/llm/default.nix" { })
    .overridePythonAttrs
      (old: {
        version = "0.31.1";
        src = final.fetchFromGitHub {
          owner = "simonw";
          repo = "llm";
          tag = "0.31.1";
          hash = "sha256-XxQ6IQyuO1rxQtiyb4VGrM7uGoffuNN5BhyI4YDxnZg=";
        };
        doCheck = false;
        meta = old.meta // {
          changelog = "https://github.com/simonw/llm/releases/tag/0.31.1";
        };
      });

  anthropic = pyPrev.anthropic.overridePythonAttrs (old: {
    version = "0.116.0";
    src = final.fetchFromGitHub {
      owner = "anthropics";
      repo = "anthropic-sdk-python";
      tag = "v0.116.0";
      hash = "sha256-HwPsGvzCeFhWNSecF2Mugj7KWIausMacrnxDLTGExaI=";
    };
    meta = old.meta // {
      changelog = "https://github.com/anthropics/anthropic-sdk-python/releases/tag/v0.116.0";
    };
  });

  llm-anthropic = pyPrev.llm-anthropic.overridePythonAttrs (_: {
    version = "0.25.1";
    doCheck = false;
    src = final.fetchurl {
      url = "https://files.pythonhosted.org/packages/source/l/llm-anthropic/llm_anthropic-0.25.1.tar.gz";
      hash = "sha256-end39zNBj6qRr3KHe0P12qY+6SZ9PvHb1X2/4MOxi64=";
    };
    dependencies = with pyFinal; [
      anthropic
      llm
    ];
  });
}
