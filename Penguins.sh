#!/bin/bash
# =============================================
# Penguins! Launcher - Steam Deck Game Mode
# =============================================
# v2.5 - Loading splash + keyboard fixes

GAME_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$GAME_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/game_$(date +%Y%m%d_%H%M%S).log"

# Show splash screen while game loads (Game Mode friendly)
show_splash() {
    if [ -f "$GAME_DIR/splash.png" ]; then
        # Use gwenview in fullscreen to show splash
        gwenview --fullscreen "$GAME_DIR/splash.png" 2>/dev/null &
        SPLASH_PID=$!
        echo "Splash PID: $SPLASH_PID" >> "$LOG_FILE"
    fi
}

# Kill splash when game window appears
kill_splash() {
    if [ -n "$SPLASH_PID" ]; then
        # Wait for Wine window to appear
        for i in {1..60}; do
            if pgrep -f "penguins.exe" >/dev/null 2>&1; then
                sleep 2  # Give game time to render
                kill $SPLASH_PID 2>/dev/null
                break
            fi
            sleep 1
        done &
    fi
}

# Show splash
show_splash

# Environment
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.steam/steam"
export STEAM_COMPAT_DATA_PATH="$GAME_DIR/prefix"
export PROTON_USE_WINED3D=1

# Steam overlay for keyboard input in Game Mode
# Note: Overlay is injected by Steam when launched from library
# Manual preload removed - causes ELF class mismatch errors

# Enable Steam input/overlay integration
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

# Kill splash when game starts
kill_splash

# Launch game from C: drive path (required by WildTangent DRM)
"$PROTON" run 'C:\Program Files (x86)\WildGames\Penguins!\penguins.exe' >> "$LOG_FILE" 2>&1
EXIT_CODE=$?

echo "Exit: $EXIT_CODE" >> "$LOG_FILE"

# Cleanup old logs (keep 10)
ls -t "$LOG_DIR"/*.log 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null

exit $EXIT_CODE
