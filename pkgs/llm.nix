{
  llmBase,
  pkgs,
}:
let
  withPluginsArgs = builtins.functionArgs llmBase.withPlugins;
  withPluginsArgNames = builtins.attrNames withPluginsArgs;
  withPlugins =
    args:
    let
      setArgs = pkgs.lib.filterAttrs (_: pkgs.lib.id) args;
      setArgNames = builtins.attrNames setArgs;
      drvName =
        let
          len = builtins.length setArgNames;
        in
        if len == 0 then
          "llm-${llmBase.version}"
        else if len > 20 then
          "llm-${llmBase.version}-with-${toString len}-plugins"
        else
          "llm-${llmBase.version}-with-${pkgs.lib.concatStringsSep "-" setArgNames}";
      plugins = pkgs.lib.intersectAttrs setArgs pkgs.python3Packages;
      pythonEnvironment = pkgs.python3.buildEnv.override {
        extraLibs = [ pkgs.python3Packages.llm ] ++ pkgs.lib.attrValues plugins;
        ignoreCollisions = true;
      };
    in
    pkgs.runCommand "${pkgs.python3.name}-${drvName}" { inherit (llmBase) meta; } ''
      mkdir -p $out/bin
      ln -s ${pythonEnvironment}/bin/llm $out/bin/llm
    '';
in
llmBase.overrideAttrs (old: {
  passthru = (old.passthru or { }) // {
    inherit withPlugins;
    withAllPlugins = withPlugins (pkgs.lib.genAttrs withPluginsArgNames (_: true));
  };
})
