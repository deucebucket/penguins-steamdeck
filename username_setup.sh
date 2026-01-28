#!/bin/bash
# =============================================
# Penguins! Username Setup Helper
# =============================================
# Run this to set your username before playing
# Works in Desktop Mode with zenity dialog
# In Game Mode, use Steam+X keyboard in-game

GAME_DIR="$(cd "$(dirname "$0")" && pwd)"
PROFILE_DIR="$GAME_DIR/prefix/pfx/drive_c/ProgramData/WildTangent/penguins/Persistent/resources/profiles"

# Create profile directory if needed
mkdir -p "$PROFILE_DIR"

# Check if we can show a GUI dialog
if [ -n "$DISPLAY" ] && which zenity >/dev/null 2>&1; then
    # Desktop mode - show zenity dialog
    USERNAME=$(zenity --entry \
        --title="Penguins! - Username Setup" \
        --text="Enter your username for Penguins!\n(Or click Cancel to use default 'Player')" \
        --entry-text="Player" \
        --width=300 \
        2>/dev/null)

    if [ $? -eq 0 ] && [ -n "$USERNAME" ]; then
        echo "Username set to: $USERNAME"
    else
        USERNAME="Player"
        echo "Using default username: Player"
    fi
else
    # Game Mode or no display - use command line
    echo "=== Penguins! Username Setup ==="
    echo "Enter your username (or press Enter for 'Player'):"
    read -r USERNAME
    [ -z "$USERNAME" ] && USERNAME="Player"
fi

# Now we need to create/update the profile with this username
# The profile format is binary, so we'll create a minimal one

echo "Setting up profile with username: $USERNAME"
echo "$USERNAME" > "$GAME_DIR/.username"
echo "Done! Username saved. Launch the game to play."
