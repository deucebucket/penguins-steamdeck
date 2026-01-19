#!/bin/bash
# ============================================
# 🐧 Penguins! - Steam Deck Installer
# ============================================
# One-click installer for Game Mode!
#
# Fixes applied:
# - vcrun2005 runtime (fixes runtime error)
# - WildTangent registry keys
# - PROTON_USE_WINED3D for display compatibility
# - Resolution config for 800p
#
# Usage: ./install.sh
# Then switch to Game Mode and play!
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
DOWNLOAD_URL="https://archive.org/download/penguins2006/Penguins%21.zip"
VCRUN_URL="https://download.microsoft.com/download/8/B/4/8B42259F-5D70-43F4-AC2E-4B208FD8D66A/vcredist_x86.EXE"
TEMP_DIR="/tmp/penguins_install"

# Find best Proton
find_proton() {
    # Prefer GE-Proton, then newer Proton versions
    for p in \
        "$HOME/.steam/steam/compatibilitytools.d/GE-Proton"*/proton \
        "$HOME/.steam/steam/steamapps/common/Proton - Experimental/proton" \
        "$HOME/.steam/steam/steamapps/common/Proton 9"*/proton \
        "$HOME/.steam/steam/steamapps/common/Proton 8"*/proton \
        "$HOME/.steam/steam/steamapps/common/Proton 7"*/proton; do
        if [ -f "$p" ]; then
            echo "$p"
            return
        fi
    done
    echo ""
}

clear
echo -e "${CYAN}"
cat << 'BANNER'
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║     🐧🐧🐧  PENGUINS!  🐧🐧🐧                                 ║
║                                                               ║
║     Wild Tangent Classic (2006)                               ║
║     Steam Deck Installer - Game Mode Ready!                   ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
BANNER
echo -e "${NC}"

# ============================================
# STEP 1: Check requirements
# ============================================
echo -e "${BLUE}[1/8] Checking requirements...${NC}"

for cmd in unzip curl python3; do
    if command -v $cmd &> /dev/null; then
        echo -e "${GREEN}  ✓ $cmd${NC}"
    else
        echo -e "${RED}  ✗ $cmd not found${NC}"
        exit 1
    fi
done

PROTON=$(find_proton)
if [ -z "$PROTON" ]; then
    echo -e "${RED}  ✗ No Proton found. Install Proton from Steam first.${NC}"
    exit 1
fi
PROTON_DIR=$(dirname "$PROTON")
PROTON_NAME=$(basename "$PROTON_DIR")
echo -e "${GREEN}  ✓ Found: $PROTON_NAME${NC}"

# ============================================
# STEP 2: Create directories
# ============================================
echo -e "${BLUE}[2/8] Creating directories...${NC}"
rm -rf "$INSTALL_DIR" 2>/dev/null
mkdir -p "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR/prefix"
mkdir -p "$TEMP_DIR"
echo -e "${GREEN}  ✓ $INSTALL_DIR${NC}"

# ============================================
# STEP 3: Download game
# ============================================
echo -e "${BLUE}[3/8] Downloading Penguins! from Archive.org...${NC}"
if [ -f "$TEMP_DIR/Penguins.zip" ]; then
    echo -e "${YELLOW}  Using cached download...${NC}"
else
    curl -L --progress-bar -o "$TEMP_DIR/Penguins.zip" "$DOWNLOAD_URL"
fi
echo -e "${GREEN}  ✓ Downloaded $(du -h "$TEMP_DIR/Penguins.zip" | cut -f1)${NC}"

# ============================================
# STEP 4: Extract game
# ============================================
echo -e "${BLUE}[4/8] Extracting game files...${NC}"
rm -rf "$TEMP_DIR/extracted" 2>/dev/null
unzip -q -o "$TEMP_DIR/Penguins.zip" -d "$TEMP_DIR/extracted"

# Find and copy game files
GAME_FOLDER=$(find "$TEMP_DIR/extracted" -type d -iname "Penguins*" 2>/dev/null | head -1)
[ -z "$GAME_FOLDER" ] && GAME_FOLDER="$TEMP_DIR/extracted"

cp -r "$GAME_FOLDER"/* "$INSTALL_DIR/" 2>/dev/null || cp -r "$TEMP_DIR/extracted"/* "$INSTALL_DIR/"
echo -e "${GREEN}  ✓ Extracted game files${NC}"

# ============================================
# STEP 5: Create Proton prefix
# ============================================
echo -e "${BLUE}[5/8] Creating Proton prefix...${NC}"
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.steam/steam"
export STEAM_COMPAT_DATA_PATH="$INSTALL_DIR/prefix"

# Initialize prefix
"$PROTON" run cmd /c "echo Prefix created" > /dev/null 2>&1
echo -e "${GREEN}  ✓ Prefix initialized${NC}"

# ============================================
# STEP 6: Install VC++ 2005 Runtime
# ============================================
echo -e "${BLUE}[6/8] Installing Visual C++ 2005 Runtime...${NC}"
echo -e "${YELLOW}  (This fixes the runtime error)${NC}"

if [ ! -f "$TEMP_DIR/vcredist2005_x86.exe" ]; then
    curl -L -o "$TEMP_DIR/vcredist2005_x86.exe" "$VCRUN_URL" 2>/dev/null
fi

# Run installer silently
DISPLAY=:0 "$PROTON" run "$TEMP_DIR/vcredist2005_x86.exe" /q > /dev/null 2>&1 &
VCPID=$!

# Wait for install (max 60 seconds)
for i in {1..12}; do
    sleep 5
    if ! kill -0 $VCPID 2>/dev/null; then
        break
    fi
    echo -e "${YELLOW}  Installing... ($((i*5))s)${NC}"
done
kill $VCPID 2>/dev/null || true

# Verify
if ls "$INSTALL_DIR/prefix/pfx/drive_c/windows/system32/msvcm80.dll" > /dev/null 2>&1; then
    echo -e "${GREEN}  ✓ VC++ 2005 installed${NC}"
else
    echo -e "${YELLOW}  ⚠ VC++ may not have installed fully - game might still work${NC}"
fi

# ============================================
# STEP 7: Setup game in prefix
# ============================================
echo -e "${BLUE}[7/8] Configuring game...${NC}"

# Create Windows game directory
WIN_GAME_DIR="$INSTALL_DIR/prefix/pfx/drive_c/Program Files (x86)/WildGames/Penguins!"
mkdir -p "$WIN_GAME_DIR"

# Copy game files
cp "$INSTALL_DIR"/*.exe "$WIN_GAME_DIR/" 2>/dev/null
cp "$INSTALL_DIR"/*.dll "$WIN_GAME_DIR/" 2>/dev/null
cp "$INSTALL_DIR"/*.ico "$WIN_GAME_DIR/" 2>/dev/null
cp "$INSTALL_DIR"/*.bmp "$WIN_GAME_DIR/" 2>/dev/null
cp -r "$INSTALL_DIR/Resources" "$WIN_GAME_DIR/" 2>/dev/null
cp -r "$INSTALL_DIR/help" "$WIN_GAME_DIR/" 2>/dev/null
cp -r "$INSTALL_DIR/LocalHTML" "$WIN_GAME_DIR/" 2>/dev/null
cp -r "$INSTALL_DIR/junk" "$WIN_GAME_DIR/" 2>/dev/null

# Create WildTangent registry
WINE_PATH="$PROTON_DIR/files/bin/wine"
if [ -f "$WINE_PATH" ]; then
    REG_FILE="$TEMP_DIR/wildtangent.reg"
    cat > "$REG_FILE" << 'REGEOF'
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\WildTangent]

[HKEY_LOCAL_MACHINE\SOFTWARE\WildTangent\Branding]
"DP"="wildgames"

[HKEY_LOCAL_MACHINE\SOFTWARE\WildTangent\InstalledSKUs\WT011554]
"ProductDisplayName"="Penguins!"
"ProductGUID"="f405496e-4cd5-4891-a8bc-3e58bd47b25c"
"InstallDirectory"="C:\\Program Files (x86)\\WildGames\\Penguins!"
"ExeName"="penguins.exe"
"RuntimeExeName"="penguins.exe"
"HideBuyButton"="1"

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\WildTangent\InstalledSKUs\WT011554]
"ProductDisplayName"="Penguins!"
"ProductGUID"="f405496e-4cd5-4891-a8bc-3e58bd47b25c"
"InstallDirectory"="C:\\Program Files (x86)\\WildGames\\Penguins!"
"ExeName"="penguins.exe"
"RuntimeExeName"="penguins.exe"
"HideBuyButton"="1"
REGEOF

    WINEPREFIX="$INSTALL_DIR/prefix/pfx" "$WINE_PATH" regedit "$REG_FILE" > /dev/null 2>&1
    echo -e "${GREEN}  ✓ Registry configured${NC}"
fi

# Set resolution for Steam Deck (800p)
mkdir -p "$INSTALL_DIR/prefix/pfx/drive_c/ProgramData/WildTangent/Penguins"
cat > "$INSTALL_DIR/prefix/pfx/drive_c/ProgramData/WildTangent/Penguins/Persistent" << EOF
SCREENWIDTH=1280
SCREENHEIGHT=800
FULLSCREEN=1
EOF
echo -e "${GREEN}  ✓ Resolution set to 1280x800${NC}"

# ============================================
# STEP 8: Create launcher and add to Steam
# ============================================
echo -e "${BLUE}[8/8] Creating launcher and adding to Steam...${NC}"

# Create launch script
cat > "$INSTALL_DIR/Penguins.sh" << LAUNCHER
#!/bin/bash
# Penguins! Launcher for Steam Deck Game Mode

cd "\$(dirname "\$0")"

export STEAM_COMPAT_CLIENT_INSTALL_PATH="\$HOME/.steam/steam"
export STEAM_COMPAT_DATA_PATH="\$PWD/prefix"
export PROTON_USE_WINED3D=1

# Find Proton
PROTON="\$HOME/.steam/steam/compatibilitytools.d/GE-Proton"*/proton
[ ! -f "\$PROTON" ] && PROTON="\$HOME/.steam/steam/steamapps/common/Proton - Experimental/proton"
[ ! -f "\$PROTON" ] && PROTON=\$(find "\$HOME/.steam/steam/steamapps/common" -name "proton" -path "*Proton*" 2>/dev/null | head -1)

if [ ! -f "\$PROTON" ]; then
    zenity --error --text="Proton not found!" 2>/dev/null
    exit 1
fi

exec "\$PROTON" run "C:\\\\Program Files (x86)\\\\WildGames\\\\Penguins!\\\\penguins.exe" "\$@"
LAUNCHER

chmod +x "$INSTALL_DIR/Penguins.sh"
echo -e "${GREEN}  ✓ Launcher created${NC}"

# Add to Steam
STEAM_USERDATA="$HOME/.steam/steam/userdata"
STEAM_USER_ID=$(ls "$STEAM_USERDATA" 2>/dev/null | grep -E '^[0-9]+$' | head -1)

if [ -n "$STEAM_USER_ID" ]; then
    SHORTCUTS_FILE="$STEAM_USERDATA/$STEAM_USER_ID/config/shortcuts.vdf"

    python3 << PYTHON_SCRIPT
import os
import struct

shortcuts_file = "$SHORTCUTS_FILE"
game_name = "Penguins!"
exe_path = "$INSTALL_DIR/Penguins.sh"
start_dir = "$INSTALL_DIR"
launch_opts = "PROTON_USE_WINED3D=1 %command%"

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
    if data[pos:pos+1] == b'\x00':
        pos += 1
        end = data.find(b'\x00', pos)
        pos = end + 1
    while pos < len(data) - 1:
        if data[pos:pos+1] == b'\x08':
            break
        if data[pos:pos+1] != b'\x00':
            pos += 1
            continue
        pos += 1
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

shortcuts = read_vdf(shortcuts_file)

# Check if already exists
for idx, entry in shortcuts.items():
    if entry.get('AppName') == game_name or entry.get('appname') == game_name:
        print("Already in Steam!")
        exit(0)

new_idx = max(shortcuts.keys(), default=-1) + 1
appid = generate_appid(exe_path, game_name)

shortcuts[new_idx] = {
    'appid': appid,
    'AppName': game_name,
    'Exe': f'"{exe_path}"',
    'StartDir': f'"{start_dir}"',
    'icon': '',
    'ShortcutPath': '',
    'LaunchOptions': launch_opts,
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

if os.path.exists(shortcuts_file):
    import shutil
    shutil.copy(shortcuts_file, shortcuts_file + '.bak')

os.makedirs(os.path.dirname(shortcuts_file), exist_ok=True)
write_vdf(shortcuts_file, shortcuts)
print("Added to Steam!")
PYTHON_SCRIPT

    echo -e "${GREEN}  ✓ Added to Steam library${NC}"
else
    echo -e "${YELLOW}  ⚠ Could not find Steam user - add manually${NC}"
fi

# Cleanup
rm -rf "$TEMP_DIR/extracted" 2>/dev/null

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
echo -e "${YELLOW}▶ TO PLAY:${NC}"
echo "  1. Switch to Game Mode (or restart Steam in Desktop Mode)"
echo "  2. Find 'Penguins!' in your Steam library"
echo "  3. Play! Use touch screen to drag gadgets"
echo ""
echo -e "${YELLOW}▶ CONTROLS (Game Mode):${NC}"
echo "  Touch Screen  → Tap and drag (best!)"
echo "  Right Pad     → Mouse cursor"
echo "  R2 Trigger    → Left click"
echo "  L2 Trigger    → Right click (rotate)"
echo ""
echo -e "${CYAN}Note: Game works in Game Mode. Desktop Mode may have display issues.${NC}"
echo ""

# Prompt to restart Steam
read -t 30 -p "Restart Steam now to see the game? (y/n) " -n 1 -r REPLY || REPLY="n"
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Restarting Steam..."
    pkill -x steam 2>/dev/null || true
    sleep 2
    nohup steam &>/dev/null &
    echo -e "${GREEN}Steam restarting. Switch to Game Mode to play!${NC}"
fi
