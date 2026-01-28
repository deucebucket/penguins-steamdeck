#!/bin/bash
# =============================================
# Penguins! Launcher - Steam Deck Game Mode
# =============================================
# v2.4 - Level transition crash FIXED!

GAME_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$GAME_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/game_$(date +%Y%m%d_%H%M%S).log"

# Environment
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.steam/steam"
export STEAM_COMPAT_DATA_PATH="$GAME_DIR/prefix"
export PROTON_USE_WINED3D=1

# Steam overlay for keyboard input in Game Mode
# Preload Steam overlay renderer for virtual keyboard support
if [ -f "$HOME/.steam/steam/ubuntu12_32/gameoverlayrenderer.so" ]; then
    export LD_PRELOAD="$HOME/.steam/steam/ubuntu12_32/gameoverlayrenderer.so${LD_PRELOAD:+:$LD_PRELOAD}"
fi

# Enable Steam input/overlay integration
export STEAM_OVERLAY_DEBUG=1
export SteamGameId=penguins
export SteamAppId=0

# CRITICAL FIX: Disable Gecko/mshtml to prevent level transition crashes
# The WildTangent engine uses Mozilla Gecko which has use-after-free bugs in Wine
export WINEDLLOVERRIDES="d3d8=n;mshtml=;gecko="

# Performance tweaks for old game
export PROTON_NO_ESYNC=1
export PROTON_NO_FSYNC=1

# Find Proton 5.0 (only version that works)
PROTON="$HOME/.steam/steam/steamapps/common/Proton 5.0/proton"
[ ! -f "$PROTON" ] && PROTON=$(find "$HOME/.steam/steam/steamapps/common" -name "proton" -path "*Proton 5*" 2>/dev/null | head -1)
[ ! -f "$PROTON" ] && PROTON=$(find "$HOME/.steam/steam/steamapps/common" -name "proton" -path "*Proton*" 2>/dev/null | head -1)

if [ ! -f "$PROTON" ]; then
    zenity --error --text="Proton not found! Install Proton 5.0 from Steam." 2>/dev/null || echo "ERROR: No Proton"
    exit 1
fi

# Log
{
    echo "=== Penguins! v2.4 ==="
    echo "Date: $(date)"
    echo "Proton: $PROTON"
    echo "DLL Overrides: $WINEDLLOVERRIDES"
    echo "===================="
} > "$LOG_FILE" 2>&1

# Launch game from C: drive path (required by WildTangent DRM)
"$PROTON" run 'C:\Program Files (x86)\WildGames\Penguins!\penguins.exe' >> "$LOG_FILE" 2>&1
EXIT_CODE=$?

echo "Exit: $EXIT_CODE" >> "$LOG_FILE"

# Cleanup old logs (keep 10)
ls -t "$LOG_DIR"/*.log 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null

exit $EXIT_CODE
