#!/bin/bash
# ================================================
# Penguins! Steam Deck - ONE CLICK BOOTSTRAP
# ================================================
# This script downloads and installs everything!
# Just run: curl -sL https://raw.githubusercontent.com/deucebucket/penguins-steamdeck/main/bootstrap.sh | bash
# ================================================

set -e

echo ""
echo "  🐧🐧🐧 PENGUINS! ONE-CLICK INSTALLER 🐧🐧🐧"
echo ""
echo "  Downloading and installing Penguins! for Steam Deck..."
echo ""

# Create game directory
INSTALL_DIR="$HOME/Games/Penguins"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Download the repo as a zip
echo "  [1/3] Downloading game files..."
curl -sL https://github.com/deucebucket/penguins-steamdeck/archive/refs/heads/main.zip -o /tmp/penguins.zip

# Extract
echo "  [2/3] Extracting..."
unzip -q -o /tmp/penguins.zip -d /tmp/
cp -rf /tmp/penguins-steamdeck-main/* "$INSTALL_DIR/"
rm -rf /tmp/penguins.zip /tmp/penguins-steamdeck-main

# Make installer executable and run it
chmod +x "$INSTALL_DIR/install.sh"
echo "  [3/3] Running installer..."
echo ""

# Run the actual installer
"$INSTALL_DIR/install.sh"
