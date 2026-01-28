#!/bin/bash
# =============================================
# Steam Text Input Helper for Penguins!
# =============================================
# This script provides a text input dialog that works in Game Mode
# Bind this to a Steam Input action (e.g., Steam + Y)
#
# How it works:
# 1. Pauses the game window
# 2. Shows text input dialog
# 3. Types the text into the game using xdotool
# 4. Resumes the game

GAME_DIR="$(cd "$(dirname "$0")" && pwd)"

# Get the prompt from argument or use default
PROMPT="${1:-Enter text for the game:}"

# Store current active window
GAME_WINDOW=$(DISPLAY=:0 xdotool getactivewindow 2>/dev/null)

# Show text input using kdialog (KDE) or zenity (GTK)
# kdialog works better in Steam Deck's KDE environment
if which kdialog >/dev/null 2>&1; then
    TEXT=$(DISPLAY=:0 kdialog --inputbox "$PROMPT" "")
    RESULT=$?
elif which zenity >/dev/null 2>&1; then
    TEXT=$(DISPLAY=:0 zenity --entry --title="Text Input" --text="$PROMPT" 2>/dev/null)
    RESULT=$?
else
    echo "No dialog tool available"
    exit 1
fi

# If user entered text, type it into the game
if [ $RESULT -eq 0 ] && [ -n "$TEXT" ]; then
    # Refocus the game window
    if [ -n "$GAME_WINDOW" ]; then
        DISPLAY=:0 xdotool windowactivate --sync "$GAME_WINDOW" 2>/dev/null
    fi

    # Small delay for focus
    sleep 0.2

    # Type the text
    DISPLAY=:0 xdotool type --clearmodifiers --delay 30 "$TEXT"

    echo "Typed: $TEXT"
fi
