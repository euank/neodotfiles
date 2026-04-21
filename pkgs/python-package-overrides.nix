{
  final,
  inputs,
}:
pyFinal: pyPrev: {
  llm =
    (pyFinal.callPackage "${inputs.nixpkgs}/pkgs/development/python-modules/llm/default.nix" { })
    .overridePythonAttrs
      (_: {
        doCheck = false;
      });

  anthropic = pyPrev.anthropic.overridePythonAttrs (_: {
    version = "0.96.0";
    src = final.fetchurl {
      url = "https://files.pythonhosted.org/packages/b9/7e/672f533dee813028d2c699bfd2a7f52c9118d7353680d9aa44b9e23f717f/anthropic-0.96.0.tar.gz";
      hash = "sha256-nelHtzfzlFL2iqUg8cIjnUQRnJtzsPttTmyoDwAnnuY=";
    };
  });

  llm-anthropic = pyPrev.llm-anthropic.overridePythonAttrs (_: {
    version = "0.25";
    doCheck = false;
    src = final.fetchurl {
      url = "https://files.pythonhosted.org/packages/74/02/574edce070d934caf8016c616ce44b90a45047331ca1470287b3c31436d2/llm_anthropic-0.25.tar.gz";
      hash = "sha256-clPBxatE08FautXDV8ALaECrwBoSboJFGFEz1WVld44=";
    };
    dependencies = with pyFinal; [
      anthropic
      json-schema-to-pydantic
      llm
    ];
  });
}
