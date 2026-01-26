#!/bin/bash
# ============================================
# Penguins! - Steam Deck Launcher
# ============================================
# Version: 0.3.0
# GitHub: https://github.com/deucebucket/penguins-steamdeck
#
# IMPORTANT: For best experience, run in GAME MODE!
# Desktop Mode has mouse coordinate offset issues.
#
# CRITICAL: Must run from C: drive path, NOT Z: drive!
# ============================================

GAME_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$GAME_DIR/logs"
CRASH_LOG="$LOG_DIR/crash_$(date +%Y%m%d_%H%M%S).log"
GITHUB_REPO="deucebucket/penguins-steamdeck"

# Create logs directory
mkdir -p "$LOG_DIR"

# Setup environment
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.steam/steam"
export STEAM_COMPAT_DATA_PATH="$GAME_DIR/prefix"
export PROTON_USE_WINED3D=1
export WINEDLLOVERRIDES="d3d8=n"

# Find Proton 5.0 (required for compatibility)
PROTON="$HOME/.steam/steam/steamapps/common/Proton 5.0/proton"
if [ ! -f "$PROTON" ]; then
    for p in \
        "$HOME/.steam/steam/steamapps/common/Proton 5"*/proton \
        "$HOME/.steam/steam/steamapps/common/Proton 6"*/proton \
        "$HOME/.steam/steam/steamapps/common/Proton - Experimental/proton" \
        "$HOME/.steam/steam/compatibilitytools.d/GE-Proton"*/proton; do
        if [ -f "$p" ]; then
            PROTON="$p"
            break
        fi
    done
fi

if [ ! -f "$PROTON" ]; then
    zenity --error --text="Proton not found! Install Proton 5.0 from Steam." 2>/dev/null || \
        echo "ERROR: Proton not found!"
    exit 1
fi

# Log system info
{
    echo "=== Penguins! Crash Report ==="
    echo "Date: $(date)"
    echo "Proton: $PROTON"
    echo "Game Dir: $GAME_DIR"
    echo "Display: $DISPLAY"
    echo "SteamOS Session: ${SteamOS_Session:-unknown}"
    echo ""
    echo "=== System Info ==="
    uname -a
    echo ""
    echo "=== Game Output ==="
} > "$CRASH_LOG" 2>&1

# CRITICAL: Launch from C: drive path (not Z: drive)
# The game validates its installation path
"$PROTON" run 'C:\Program Files (x86)\WildGames\Penguins!\penguins.exe' "$@" >> "$CRASH_LOG" 2>&1
EXIT_CODE=$?

# Check for crash
if [ $EXIT_CODE -ne 0 ]; then
    {
        echo ""
        echo "=== EXIT CODE: $EXIT_CODE ==="
        echo ""
        echo "To report issues:"
        echo "1. Open: https://github.com/$GITHUB_REPO/issues/new"
        echo "2. Title: 'Bug Report - $(date +%Y-%m-%d)'"
        echo "3. Attach this log file"
        echo ""
        echo "Log file: $CRASH_LOG"
    } >> "$CRASH_LOG"

    # Show notification in Desktop Mode
    if command -v zenity &>/dev/null && [ -n "$DISPLAY" ] && [ -z "$SteamOS_Session" ]; then
        zenity --warning --title="Penguins!" \
            --text="Game exited with code $EXIT_CODE\n\nLog saved to:\n$CRASH_LOG\n\nReport issues at:\nhttps://github.com/$GITHUB_REPO/issues" \
            --width=400 2>/dev/null &
    fi
fi

# Cleanup old logs (keep last 10)
ls -t "$LOG_DIR"/crash_*.log 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null

exit $EXIT_CODE
