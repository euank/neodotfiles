# Only source this once.
if [ -n "$__HM_SESS_VARS_SOURCED" ]; then return; fi
export __HM_SESS_VARS_SOURCED=1

export COWPATH="/nix/store/500s9r282xjq81dqssjc2n2kll39jwcq-cowsay-3.8.4/share/cows:/nix/store/ls9m89db99x0x8qm9a0rk66y983ps6q0-tewisay-0-unstable-2022-11-04/share/tewisay/cows"
export DISPLAY=":0"
export EDITOR="nvim"
export GLFW_IM_MODULE="ibus"
export GLFW_SO_PATH="/nix/store/5yi2sms4b014lczhifa75yxvf7s70rbf-glfw-3.4/lib/libglfw.so"
export GTK2_RC_FILES="/home/esk/.gtkrc-2.0"
export LOCALE_ARCHIVE_2_27="/nix/store/xn4b1ss8cqfwf7iq5ipzm9yjh7gip7vl-glibc-locales-2.40-66/lib/locale/locale-archive"
export NIXOS_OZONE_WL="1"
export NIX_DEBUG_INFO_DIRS="/run/dwarffs"
export OPENAL_SO_PATH="/nix/store/6qajzq1xzdy1jal0zx4clvnq85xmaqic-openal-soft-1.24.2/lib/libopenal.so"
export PKG_CONFIG_PATH="/nix/store/k0699a27nkj4c2xn67bjcpfa08nqn9l4-openssl-3.4.1-dev/lib/pkgconfig:/nix/store/vhq4bnb1bnj8np140md08mbxz51an0h2-opencv-4.11.0/lib/pkgconfig:/nix/store/qyp8pcm3xr5ww1r4rj752zpny6awvbqf-libX11-1.8.12-dev/lib/pkgconfig:/nix/store/n04k2sr8gzh42kx2lv5mw5n4xbyljfl7-libXrandr-1.5.4-dev/lib/pkgconfig:/nix/store/5dkrbiki8nam56qqnxnm4mvbpxa1v4qb-libxcb-1.17.0-dev/lib/pkgconfig:/nix/store/sswwzy51q13svri19m61n4awxb0ma14d-libopus-1.5.2-dev/lib/pkgconfig:/nix/store/q70y1hc004sa6h8hd4jvg3l8ybwa11r1-sqlite-3.50.1-dev/lib/pkgconfig:/nix/store/cxy5q3kn7aq9dp3bffznb37gzflanfk5-systemd-minimal-libs-257.6-dev/lib/pkgconfig:/nix/store/6r4zqb04fq5l5l4zghq76wvcpz7dwd35-linux-pam-1.6.1/lib/pkgconfig:/nix/store/697yd6r0ar3b0anda6f3nhnwkv45qa9g-elfutils-0.193-dev/lib/pkgconfig:/nix/store/a9nkmnva7vam9awlkn8ri3fa0kq93frn-ncurses-6.5-dev/lib/pkgconfig"
export PROTOC="/nix/store/4xb12lr8fmh4jv1gp1c9f3qcvfwxfra9-protobuf-31.1/bin/protoc"
export SDL_IM_MODULE="fcitx"
export XCURSOR_SIZE="12"
export XCURSOR_THEME="graphite-light"
export XDG_CACHE_HOME="/home/esk/.cache"
export XDG_CONFIG_HOME="/home/esk/.config"
export XDG_DATA_DIRS="/nix/store/5hs71yqf4hgs8p1w25n3wi9m0ai04z93-network-manager-applet-1.36.0/share${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"
export XDG_DATA_HOME="/home/esk/.local/share"
export XDG_DESKTOP_DIR="$HOME/Desktop"
export XDG_DOCUMENTS_DIR="$HOME/Documents"
export XDG_DOWNLOAD_DIR="$HOME/Downloads"
export XDG_MUSIC_DIR="$HOME/Music"
export XDG_PICTURES_DIR="$HOME/Pictures"
export XDG_PUBLICSHARE_DIR="$HOME/share/public"
export XDG_STATE_HOME="/home/esk/.local/state"
export XDG_TEMPLATES_DIR="$HOME/Templates"
export XDG_VIDEOS_DIR="$HOME/Videos"
export XMODIFIERS="@im=fcitx"
export QT_PLUGIN_PATH="/nix/store/1vds3862p083q06aw08hz3p50vai1680-fcitx5-with-addons-5.1.12/lib/qt-6/plugins${QT_PLUGIN_PATH:+:}$QT_PLUGIN_PATH"
export XCURSOR_PATH="/etc/profiles/per-user/esk/share/icons${XCURSOR_PATH:+:}$XCURSOR_PATH"
unset SSH_AGENT_PID
set -x
if [ -z "$SSH_CONNECTION" -o -z "$SSH_AUTH_SOCK" ] && [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  export SSH_AUTH_SOCK="$(/nix/store/llxp5n33a0l8fbhvhmgq5l8kvz8c887j-gnupg-2.4.7/bin/gpgconf --list-dirs agent-ssh-socket)"
fi
set +x
