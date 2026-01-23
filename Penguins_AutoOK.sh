#!/bin/bash
# Penguins! Launcher - minimizes error dialogs so game is playable

cd "$(dirname "$0")"

export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.steam/steam"
export STEAM_COMPAT_DATA_PATH="$PWD/prefix"

PROTON="$HOME/.steam/steam/steamapps/common/Proton 5.0/proton"
[ ! -f "$PROTON" ] && PROTON="$HOME/.steam/steam/steamapps/common/Proton 6.3/proton"
[ ! -f "$PROTON" ] && PROTON=$(find "$HOME/.steam/steam/steamapps/common" -name "proton" -path "*Proton*" 2>/dev/null | head -1)

if [ ! -f "$PROTON" ]; then
    zenity --error --text="Proton not found!" 2>/dev/null
    exit 1
fi

# Start dialog handler in background - minimizes error dialogs
(
    sleep 2
    while true; do
        # Find Runtime error dialogs and minimize them
        for WID in $(DISPLAY=:0 xdotool search --name "Runtime" 2>/dev/null); do
            DISPLAY=:0 xdotool windowminimize "$WID" 2>/dev/null
        done
        # Also handle Microsoft Visual dialogs
        for WID in $(DISPLAY=:0 xdotool search --name "Microsoft Visual" 2>/dev/null); do
            DISPLAY=:0 xdotool windowminimize "$WID" 2>/dev/null
        done
        sleep 0.5
    done
) &
HANDLER_PID=$!

# Start the game
"$PROTON" run "C:\\Program Files (x86)\\WildGames\\Penguins!\\penguins.exe"

# Kill handler daemon when game exits
kill $HANDLER_PID 2>/dev/null
