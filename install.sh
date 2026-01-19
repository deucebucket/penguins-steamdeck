#!/bin/bash
# ============================================
# 🐧 Penguins! - One-Click Steam Deck Installer
# ============================================
# Downloads, installs, AND adds to Steam automatically!
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/deucebucket/penguins-steamdeck/main/install.sh | bash
#   or just double-click the .desktop file
# ============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
GAME_NAME="Penguins!"
INSTALL_DIR="$HOME/Games/Penguins"
WINE_PREFIX="$INSTALL_DIR/prefix"
DOWNLOAD_URL="https://archive.org/download/penguins2006/Penguins%21.zip"
TEMP_DIR="/tmp/penguins_install"

# Show banner
clear
echo -e "${CYAN}"
cat << 'BANNER'
 ╔═══════════════════════════════════════════════════════════════╗
 ║                                                               ║
 ║     🐧🐧🐧  PENGUINS!  🐧🐧🐧                                 ║
 ║                                                               ║
 ║     Wild Tangent Classic (2006)                               ║
 ║     Steam Deck One-Click Installer                            ║
 ║                                                               ║
 ╚═══════════════════════════════════════════════════════════════╝
BANNER
echo -e "${NC}"

# ============================================
# STEP 1: Check requirements
# ============================================
echo -e "${BLUE}[1/6] Checking requirements...${NC}"

for cmd in unzip curl python3; do
    if command -v $cmd &> /dev/null; then
        echo -e "${GREEN}  ✓ $cmd${NC}"
    else
        echo -e "${RED}  ✗ $cmd not found${NC}"
        exit 1
    fi
done

# Check Wine/Proton
if command -v wine &> /dev/null; then
    echo -e "${GREEN}  ✓ Wine${NC}"
elif [ -d "$HOME/.steam/steam/steamapps/common/Proton - Experimental" ]; then
    echo -e "${GREEN}  ✓ Proton Experimental${NC}"
else
    echo -e "${YELLOW}  ⚠ Install 'Proton Experimental' from Steam first${NC}"
    echo -e "${YELLOW}    Steam → Library → Search 'Proton' → Install${NC}"
    exit 1
fi

# ============================================
# STEP 2: Create directories
# ============================================
echo -e "${BLUE}[2/6] Creating directories...${NC}"
mkdir -p "$INSTALL_DIR"
mkdir -p "$WINE_PREFIX"
mkdir -p "$TEMP_DIR"
echo -e "${GREEN}  ✓ $INSTALL_DIR${NC}"

# ============================================
# STEP 3: Download game
# ============================================
echo -e "${BLUE}[3/6] Downloading from Archive.org...${NC}"
if [ -f "$TEMP_DIR/Penguins.zip" ]; then
    echo -e "${YELLOW}  Using cached download...${NC}"
else
    curl -L --progress-bar -o "$TEMP_DIR/Penguins.zip" "$DOWNLOAD_URL"
fi
echo -e "${GREEN}  ✓ Downloaded $(du -h "$TEMP_DIR/Penguins.zip" | cut -f1)${NC}"

# ============================================
# STEP 4: Extract game
# ============================================
echo -e "${BLUE}[4/6] Extracting game files...${NC}"
rm -rf "$TEMP_DIR/extracted"
unzip -q -o "$TEMP_DIR/Penguins.zip" -d "$TEMP_DIR/extracted"

# Find game folder
GAME_FOLDER=$(find "$TEMP_DIR/extracted" -type d -iname "Penguins*" 2>/dev/null | head -1)
[ -z "$GAME_FOLDER" ] && GAME_FOLDER="$TEMP_DIR/extracted"

cp -r "$GAME_FOLDER"/* "$INSTALL_DIR/" 2>/dev/null || cp -r "$TEMP_DIR/extracted"/* "$INSTALL_DIR/"

GAME_EXE=$(find "$INSTALL_DIR" -iname "penguins.exe" 2>/dev/null | head -1)
[ -z "$GAME_EXE" ] && GAME_EXE=$(find "$INSTALL_DIR" -iname "*.exe" ! -iname "unins*" 2>/dev/null | head -1)

if [ -z "$GAME_EXE" ]; then
    echo -e "${RED}  ✗ Could not find game executable${NC}"
    exit 1
fi
echo -e "${GREEN}  ✓ Found $(basename "$GAME_EXE")${NC}"

# ============================================
# STEP 5: Create launcher
# ============================================
echo -e "${BLUE}[5/6] Creating launcher...${NC}"

cat > "$INSTALL_DIR/Penguins.sh" << 'LAUNCHER'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

export WINEPREFIX="$SCRIPT_DIR/prefix"
export WINEDLLOVERRIDES="mscoree,mshtml="
export WINEARCH=win32

GAME_EXE=$(find "$SCRIPT_DIR" -maxdepth 3 -iname "penguins.exe" 2>/dev/null | head -1)
[ -z "$GAME_EXE" ] && GAME_EXE=$(find "$SCRIPT_DIR" -maxdepth 3 -iname "*.exe" ! -iname "unins*" 2>/dev/null | head -1)

[ -z "$GAME_EXE" ] && { zenity --error --text="Could not find game!" 2>/dev/null; exit 1; }

cd "$(dirname "$GAME_EXE")"

# Try Wine first
if command -v wine &> /dev/null; then
    exec wine "$GAME_EXE" "$@"
fi

# Fall back to Proton
PROTON="$HOME/.steam/steam/steamapps/common/Proton - Experimental/proton"
[ ! -f "$PROTON" ] && PROTON=$(find "$HOME/.steam/steam/steamapps/common" -name "proton" -path "*Proton*" 2>/dev/null | head -1)

if [ -f "$PROTON" ]; then
    export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.steam/steam"
    export STEAM_COMPAT_DATA_PATH="$WINEPREFIX"
    mkdir -p "$WINEPREFIX"
    exec "$PROTON" run "$GAME_EXE" "$@"
fi

zenity --error --text="No Wine/Proton found!" 2>/dev/null
exit 1
LAUNCHER

chmod +x "$INSTALL_DIR/Penguins.sh"
echo -e "${GREEN}  ✓ Created Penguins.sh${NC}"

# ============================================
# STEP 6: Add to Steam automatically
# ============================================
echo -e "${BLUE}[6/6] Adding to Steam library...${NC}"

# Find Steam user ID
STEAM_USERDATA="$HOME/.steam/steam/userdata"
STEAM_USER_ID=$(ls "$STEAM_USERDATA" 2>/dev/null | grep -E '^[0-9]+$' | head -1)

if [ -z "$STEAM_USER_ID" ]; then
    echo -e "${YELLOW}  ⚠ Could not find Steam user ID${NC}"
    echo -e "${YELLOW}    Add manually: Steam → Games → Add Non-Steam Game${NC}"
else
    SHORTCUTS_FILE="$STEAM_USERDATA/$STEAM_USER_ID/config/shortcuts.vdf"

    # Python script to add shortcut
    python3 << PYTHON_SCRIPT
import os
import struct

shortcuts_file = "$SHORTCUTS_FILE"
game_name = "Penguins!"
exe_path = "$INSTALL_DIR/Penguins.sh"
start_dir = "$INSTALL_DIR"
icon_path = ""

# VDF binary format helper functions
def read_vdf(filepath):
    if not os.path.exists(filepath):
        return {}
    with open(filepath, 'rb') as f:
        data = f.read()
    return parse_vdf(data)

def parse_vdf(data):
    shortcuts = {}
    pos = 0
    if len(data) < 1:
        return shortcuts
    # Skip header
    if data[pos:pos+1] == b'\x00':
        pos += 1
        # Read "shortcuts"
        end = data.find(b'\x00', pos)
        pos = end + 1

    while pos < len(data) - 1:
        if data[pos:pos+1] == b'\x08':
            break
        if data[pos:pos+1] != b'\x00':
            pos += 1
            continue
        pos += 1
        # Read index
        end = data.find(b'\x00', pos)
        if end == -1:
            break
        idx = data[pos:end].decode('utf-8', errors='ignore')
        pos = end + 1

        entry = {}
        while pos < len(data):
            type_byte = data[pos:pos+1]
            if type_byte == b'\x08':
                pos += 1
                break
            pos += 1

            end = data.find(b'\x00', pos)
            if end == -1:
                break
            key = data[pos:end].decode('utf-8', errors='ignore')
            pos = end + 1

            if type_byte == b'\x01':
                end = data.find(b'\x00', pos)
                entry[key] = data[pos:end].decode('utf-8', errors='ignore')
                pos = end + 1
            elif type_byte == b'\x02':
                entry[key] = struct.unpack('<I', data[pos:pos+4])[0]
                pos += 4
            else:
                break

        if idx.isdigit():
            shortcuts[int(idx)] = entry

    return shortcuts

def write_vdf(filepath, shortcuts):
    with open(filepath, 'wb') as f:
        f.write(b'\x00shortcuts\x00')
        for idx, entry in sorted(shortcuts.items()):
            f.write(b'\x00' + str(idx).encode() + b'\x00')
            for key, value in entry.items():
                if isinstance(value, str):
                    f.write(b'\x01' + key.encode() + b'\x00' + value.encode() + b'\x00')
                elif isinstance(value, int):
                    f.write(b'\x02' + key.encode() + b'\x00' + struct.pack('<I', value))
            f.write(b'\x08')
        f.write(b'\x08\x08')

def generate_appid(exe, name):
    import hashlib
    key = exe + name
    return (int(hashlib.md5(key.encode()).hexdigest()[:8], 16) & 0x7FFFFFFF) | 0x80000000

# Load existing shortcuts
shortcuts = read_vdf(shortcuts_file)

# Check if already exists
for idx, entry in shortcuts.items():
    if entry.get('AppName') == game_name or entry.get('appname') == game_name:
        print("  Already in Steam library!")
        exit(0)

# Add new shortcut
new_idx = max(shortcuts.keys(), default=-1) + 1
appid = generate_appid(exe_path, game_name)

shortcuts[new_idx] = {
    'appid': appid,
    'AppName': game_name,
    'Exe': f'"{exe_path}"',
    'StartDir': f'"{start_dir}"',
    'icon': icon_path,
    'ShortcutPath': '',
    'LaunchOptions': '',
    'IsHidden': 0,
    'AllowDesktopConfig': 1,
    'AllowOverlay': 1,
    'OpenVR': 0,
    'Devkit': 0,
    'DevkitGameID': '',
    'DevkitOverrideAppID': 0,
    'LastPlayTime': 0,
    'FlatpakAppID': '',
    'tags': {}
}

# Backup existing
if os.path.exists(shortcuts_file):
    import shutil
    shutil.copy(shortcuts_file, shortcuts_file + '.bak')

# Write new shortcuts
os.makedirs(os.path.dirname(shortcuts_file), exist_ok=True)
write_vdf(shortcuts_file, shortcuts)
print("  Added to Steam!")
PYTHON_SCRIPT

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}  ✓ Added to Steam library${NC}"
        echo -e "${YELLOW}  ⚠ Restart Steam to see it in Game Mode${NC}"
    else
        echo -e "${YELLOW}  ⚠ Could not auto-add. Add manually via Steam.${NC}"
    fi
fi

# Cleanup
rm -rf "$TEMP_DIR/extracted"

# ============================================
# Done!
# ============================================
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║            ✓ INSTALLATION COMPLETE! 🐧                        ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Game Location:${NC} $INSTALL_DIR"
echo ""
echo -e "${YELLOW}▶ PLAY IN GAME MODE:${NC}"
echo "  1. Restart Steam (quit and reopen)"
echo "  2. Look for 'Penguins!' in your library"
echo "  3. Use touch screen to drag gadgets!"
echo ""
echo -e "${YELLOW}▶ CONTROLS:${NC}"
echo "  Touch Screen  → Tap and drag gadgets (best way!)"
echo "  Right Pad     → Mouse cursor"
echo "  R2 Trigger    → Left click (drag)"
echo "  L2 Trigger    → Right click (rotate bridges)"
echo "  Y Button      → Fullscreen"
echo "  Start         → Pause"
echo ""

# Try to show notification on desktop
if command -v notify-send &> /dev/null; then
    notify-send -i applications-games "Penguins! Installed" "Restart Steam to play in Game Mode!" 2>/dev/null || true
fi

# Prompt to restart Steam
echo -e "${CYAN}Would you like to restart Steam now? (y/n)${NC}"
read -t 30 -n 1 -r REPLY || REPLY="n"
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Restarting Steam..."
    pkill -x steam 2>/dev/null || true
    sleep 2
    nohup steam &>/dev/null &
    echo -e "${GREEN}Steam is restarting. Look for Penguins! in your library!${NC}"
fi
