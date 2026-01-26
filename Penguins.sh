#!/bin/bash
# =============================================
# Penguins! Launcher - Steam Deck Game Mode
# =============================================
# CRITICAL: Must run from C: drive path!

GAME_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$GAME_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/game_$(date +%Y%m%d_%H%M%S).log"

# Environment
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.steam/steam"
export STEAM_COMPAT_DATA_PATH="$GAME_DIR/prefix"
export PROTON_USE_WINED3D=1
export WINEDLLOVERRIDES="d3d8=n"

# Find Proton
PROTON="$HOME/.steam/steam/steamapps/common/Proton 5.0/proton"
[ ! -f "$PROTON" ] && PROTON=$(find "$HOME/.steam/steam/steamapps/common" -name "proton" -path "*Proton 5*" 2>/dev/null | head -1)
[ ! -f "$PROTON" ] && PROTON=$(find "$HOME/.steam/steam/steamapps/common" -name "proton" -path "*Proton*" 2>/dev/null | head -1)

if [ ! -f "$PROTON" ]; then
    zenity --error --text="Proton not found! Install Proton 5.0." 2>/dev/null || echo "ERROR: No Proton"
    exit 1
fi

# Log header
{
    echo "=== Penguins! Log ==="
    echo "Date: $(date)"
    echo "Proton: $PROTON"
    echo "===================="
} > "$LOG_FILE" 2>&1

# CRITICAL: Launch from C: drive path (game validates its path!)
"$PROTON" run 'C:\Program Files (x86)\WildGames\Penguins!\penguins.exe' >> "$LOG_FILE" 2>&1
EXIT_CODE=$?

echo "Exit: $EXIT_CODE" >> "$LOG_FILE"

# Cleanup old logs (keep 10)
ls -t "$LOG_DIR"/*.log 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null

exit $EXIT_CODE
