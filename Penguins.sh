#!/bin/bash
# Penguins! Launcher for Steam Deck Game Mode

cd "$(dirname "$0")"

export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.steam/steam"
export STEAM_COMPAT_DATA_PATH="$PWD/prefix"
#export PROTON_USE_WINED3D=1

# Find Proton - try older versions first for better D3D8 compatibility
PROTON="$HOME/.steam/steam/steamapps/common/Proton 5.0/proton"
[ ! -f "$PROTON" ] && PROTON="$HOME/.steam/steam/steamapps/common/Proton 6.3/proton"
[ ! -f "$PROTON" ] && PROTON="$HOME/.steam/steam/steamapps/common/Proton - Experimental/proton"
[ ! -f "$PROTON" ] && PROTON=$(find "$HOME/.steam/steam/steamapps/common" -name "proton" -path "*Proton*" 2>/dev/null | head -1)

if [ ! -f "$PROTON" ]; then
    zenity --error --text="Proton not found!" 2>/dev/null
    exit 1
fi

exec "$PROTON" run "C:\\Program Files (x86)\\WildGames\\Penguins!\\penguins.exe" "$@"
