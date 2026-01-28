#!/bin/bash
# =============================================
# Penguins! Text Input Helper
# =============================================
# Shows a dialog to enter text, then types it into the game
# Usage: ./text_input.sh [prompt]
#
# In Game Mode: Bind to a Steam Input action
# In Desktop Mode: Run directly

PROMPT="${1:-Enter text:}"

# Try zenity first (works in Desktop mode)
if [ -n "$DISPLAY" ]; then
    TEXT=$(zenity --entry \
        --title="Penguins! Text Input" \
        --text="$PROMPT" \
        --width=300 \
        2>/dev/null)

    if [ $? -eq 0 ] && [ -n "$TEXT" ]; then
        # Small delay to let dialog close
        sleep 0.3
        # Type the text into the active window
        DISPLAY=:0 xdotool type --clearmodifiers "$TEXT"
        # Press Enter to confirm
        DISPLAY=:0 xdotool key Return
    fi
fi
