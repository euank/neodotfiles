{ pkgs }:
let
  inherit (pkgs)
    grim
    slurp
    llm
    wl-clipboard
    ;

  opener-open = pkgs.writeShellApplication {
    name = "open";
    text = ''
      if (( $# == 0 )); then
        url="$(cat)"
      else
        url="$*"
      fi

      if [[ -n "''${OPENER_SOCKET:-}" ]]; then
        socket="$OPENER_SOCKET"
      elif [[ -n "''${SSH_CONNECTION:-}" ]]; then
        socket="/tmp/opener-$(${pkgs.coreutils}/bin/id -un).sock"
      else
        socket="$HOME/.opener.sock"
      fi

      if [[ ! -S "$socket" ]]; then
        echo "open: opener socket does not exist: $socket" >&2
        exit 1
      fi

      # -N half-closes the socket after stdin reaches EOF, allowing opener to
      # finish reading the URL and close its side of the connection.
      printf '%s\n' "$url" | ${pkgs.netcat-openbsd}/bin/nc -N -U "$socket"
    '';
  };

  opener-xdg-open = pkgs.writeShellApplication {
    name = "xdg-open";
    text = ''
      if [[ -n "''${SSH_CONNECTION:-}" ]]; then
        exec ${opener-open}/bin/open "$@"
      fi
      exec ${pkgs.xdg-utils}/bin/xdg-open "$@"
    '';
  };
in
{
  opener-client = pkgs.symlinkJoin {
    name = "opener-client";
    paths = [
      opener-open
      opener-xdg-open
    ];
  };

  screenshot-area = pkgs.writeShellScriptBin "screenshot-area" ''
    selection="$(${slurp}/bin/slurp)"
    ${grim}/bin/grim -g "$selection" - | ${wl-clipboard}/bin/wl-copy -t "image/png"
  '';

  # gpt-5.2 based on https://github.com/euank/kitchen-sink/tree/0ac3b084231c3e0cd40ff7686cd3a8e9ad9b3527/model-comparison
  llm-ocr-area = pkgs.writeShellScriptBin "llm-ocr-area" ''
    selection="$(${slurp}/bin/slurp)"
    ${grim}/bin/grim -g "$selection" - | ${llm}/bin/llm -m "gpt-5.2" -a - "Please output your best guess at the Japanese characters in this image. Do not output any other text." | ${pkgs.wl-clipboard}/bin/wl-copy
  '';

  ssh-sibyl = pkgs.writeShellScriptBin "ssh-sibyl" ''
    lladdr="$(ip -j neigh get "10.57.26.254" dev wlan0 2>/dev/null | jq -cr '.[0].lladdr' 2>/dev/null || echo "")"
    if [[ "$lladdr" == "02:82:5b:c4:4c:a6" ]]; then
      # home router
      exec ssh sibyl "$@"
    else
      exec ssh sibyl-home "$@"
    fi
  '';

  ssh-enk = pkgs.writeShellScriptBin "ssh-enk" ''
    lladdr="$(ip -j neigh get "10.57.26.254" dev wlan0 2>/dev/null | jq -cr '.[0].lladdr' 2>/dev/null || echo "")"
    if [[ "$lladdr" == "02:82:5b:c4:4c:a6" ]]; then
      # home router
      exec ssh enkidudu-local "$@"
    else
      exec ssh home-enk "$@"
    fi
  '';
}
