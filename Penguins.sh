#!/bin/bash
# =============================================
# Penguins! Launcher - Steam Deck Game Mode
# =============================================
# v2.5 - Simple launcher, use manager for setup

GAME_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$GAME_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/game_$(date +%Y%m%d_%H%M%S).log"

# Environment
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.steam/steam"
export STEAM_COMPAT_DATA_PATH="$GAME_DIR/prefix"
export PROTON_USE_WINED3D=1
export SteamGameId=penguins
export SteamAppId=0

# CRITICAL FIX: Disable Gecko/mshtml to prevent level transition crashes
export WINEDLLOVERRIDES="d3d8=n;mshtml=;gecko="

# Performance tweaks
export PROTON_NO_ESYNC=1
export PROTON_NO_FSYNC=1

# Find Proton 5.0
PROTON="$HOME/.steam/steam/steamapps/common/Proton 5.0/proton"
[ ! -f "$PROTON" ] && PROTON=$(find "$HOME/.steam/steam/steamapps/common" -name "proton" -path "*Proton 5*" 2>/dev/null | head -1)

if [ ! -f "$PROTON" ]; then
    zenity --error --text="Proton not found! Install Proton 5.0 from Steam." 2>/dev/null
    exit 1
fi

# Log
echo "=== Penguins! v2.5 === $(date)" > "$LOG_FILE"

# Launch game
"$PROTON" run 'C:\Program Files (x86)\WildGames\Penguins!\penguins.exe' >> "$LOG_FILE" 2>&1
exit $?
