#!/bin/bash
# ============================================
# 🐧 Penguins! - Steam Deck One-Click Installer
# ============================================
# Version: 2.0.0
# GitHub: https://github.com/deucebucket/penguins-steamdeck
#
# This installer handles EVERYTHING:
# ✓ Wine prefix setup
# ✓ DRM bypass patches
# ✓ d3d8to9 wrapper
# ✓ Virtual desktop config
# ✓ Adds to Steam with artwork
# ✓ Game Mode ready!
# ============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Get script directory (where game files are)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="$SCRIPT_DIR"
PREFIX_DIR="$INSTALL_DIR/prefix"
STEAM_DIR="$HOME/.steam/steam"

# Wine paths
WINE_GAME_PATH='C:\Program Files (x86)\WildGames\Penguins!'
LINUX_GAME_PATH="$PREFIX_DIR/pfx/drive_c/Program Files (x86)/WildGames/Penguins!"

clear
echo -e "${CYAN}"
cat << 'BANNER'
    _______________________________________________________________
   |                                                               |
   |        (o>    ____  _____ _   _  ____ _   _ ___ _   _ ____    |
   |        //\   |  _ \| ____| \ | |/ ___| | | |_ _| \ | / ___|   |
   |       V_/_   | |_) |  _| |  \| | |  _| | | || ||  \| \___ \   |
   |        ||    |  __/| |___| |\  | |_| | |_| || || |\  |___) |  |
   |       ^^^^   |_|   |_____|_| \_|\____|\___/|___|_| \_|____/   |
   |                                                               |
   |     (o>  (o>      WildTangent Classic (2006)          <o)     |
   |     //\  //\      Steam Deck Installer v2.2           /\\     |
   |    V_/_ V_/_                                         _\_V     |
   |_______________________________________________________________|

BANNER
echo -e "${NC}"

# ============================================
# STEP 1: Check requirements
# ============================================
echo -e "${BLUE}[1/7] Checking requirements...${NC}"

# Check for game files
if [ ! -f "$SCRIPT_DIR/penguins.exe" ]; then
    echo -e "${RED}ERROR: penguins.exe not found!${NC}"
    echo "Make sure you're running this from the game directory."
    exit 1
fi
echo -e "${GREEN}  ✓ Game files found${NC}"

# Find Proton 5.0 (required for this game)
PROTON=""
for p in \
    "$STEAM_DIR/steamapps/common/Proton 5.0/proton" \
    "$STEAM_DIR/steamapps/common/Proton 5"*/proton \
    "$STEAM_DIR/steamapps/common/Proton 6"*/proton \
    "$STEAM_DIR/steamapps/common/Proton - Experimental/proton"; do
    if [ -f "$p" ]; then
        PROTON="$p"
        break
    fi
done

if [ -z "$PROTON" ]; then
    echo -e "${RED}ERROR: Proton not found!${NC}"
    echo ""
    echo "Install Proton 5.0 from Steam:"
    echo "  Library → Tools → Search 'Proton 5.0' → Install"
    exit 1
fi

PROTON_DIR="$(dirname "$PROTON")"
PROTON_NAME="$(basename "$PROTON_DIR")"
WINE_BIN="$PROTON_DIR/dist/bin/wine"
echo -e "${GREEN}  ✓ Found: $PROTON_NAME${NC}"

# ============================================
# STEP 2: Create Wine prefix
# ============================================
echo -e "${BLUE}[2/7] Setting up Wine prefix...${NC}"

mkdir -p "$PREFIX_DIR"
mkdir -p "$INSTALL_DIR/logs"

# Check if we have a pre-configured prefix to use
if [ -d "$SCRIPT_DIR/prefix_template/pfx" ]; then
    # Use pre-configured prefix template (includes all registry entries)
    echo -e "${CYAN}  Using pre-configured prefix template...${NC}"
    cp -r "$SCRIPT_DIR/prefix_template"/* "$PREFIX_DIR/" 2>/dev/null || true
elif [ ! -f "$PREFIX_DIR/pfx/system.reg" ]; then
    # Initialize fresh prefix
    export WINEPREFIX="$PREFIX_DIR/pfx"
    export STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAM_DIR"
    export STEAM_COMPAT_DATA_PATH="$PREFIX_DIR"

    echo -e "${CYAN}  Initializing Wine prefix (this may take a moment)...${NC}"
    "$PROTON" run wineboot --init 2>/dev/null || true
    sleep 3

    # Run a dummy command to fully initialize directx/video codecs
    "$PROTON" run cmd /c "echo initialized" 2>/dev/null || true
    sleep 2
fi

mkdir -p "$LINUX_GAME_PATH"
echo -e "${GREEN}  ✓ Wine prefix ready${NC}"

# ============================================
# STEP 3: Install game to C: drive
# ============================================
echo -e "${BLUE}[3/7] Installing game files...${NC}"

# Copy all game files to Wine C: drive
# Copy all game files comprehensively
cp -f "$SCRIPT_DIR/penguins.exe" "$LINUX_GAME_PATH/" 2>/dev/null || true
cp -rf "$SCRIPT_DIR/Resources" "$LINUX_GAME_PATH/" 2>/dev/null || true
cp -rf "$SCRIPT_DIR/junk" "$LINUX_GAME_PATH/" 2>/dev/null || true
cp -rf "$SCRIPT_DIR/help" "$LINUX_GAME_PATH/" 2>/dev/null || true
cp -rf "$SCRIPT_DIR/LocalHTML" "$LINUX_GAME_PATH/" 2>/dev/null || true
cp -rf "$SCRIPT_DIR/local_assets" "$LINUX_GAME_PATH/" 2>/dev/null || true

# Copy all DLLs, HTML, INI, and other support files
for f in "$SCRIPT_DIR"/*.dll "$SCRIPT_DIR"/*.ini "$SCRIPT_DIR"/*.dat "$SCRIPT_DIR"/*.html "$SCRIPT_DIR"/*.txt; do
    [ -f "$f" ] && cp -f "$f" "$LINUX_GAME_PATH/" 2>/dev/null || true
done

echo -e "${GREEN}  ✓ Game files installed to C: drive${NC}"

# ============================================
# STEP 4: Apply DRM bypass patches
# ============================================
echo -e "${BLUE}[4/7] Applying DRM bypass patches...${NC}"

GAME_EXE="$LINUX_GAME_PATH/penguins.exe"

# Check if already patched
BYTE=$(xxd -s 0xec185 -l 1 "$GAME_EXE" 2>/dev/null | awk '{print $2}')
if [ "$BYTE" = "eb" ]; then
    echo -e "${GREEN}  ✓ Already patched${NC}"
else
    # Patch 1: 0xec185: 74 15 -> eb 15 (je -> jmp) - Skip registry error
    printf '\xeb\x15' | dd of="$GAME_EXE" bs=1 seek=$((0xec185)) conv=notrunc 2>/dev/null

    # Patch 2: 0xec408: jz -> NOPs - Skip SKU check #1
    printf '\x90\x90\x90\x90\x90\x90' | dd of="$GAME_EXE" bs=1 seek=$((0xec408)) conv=notrunc 2>/dev/null

    # Patch 3: 0xec46b: jle -> NOPs - Skip SKU check #2
    printf '\x90\x90' | dd of="$GAME_EXE" bs=1 seek=$((0xec46b)) conv=notrunc 2>/dev/null

    echo -e "${GREEN}  ✓ DRM bypass applied (3 patches)${NC}"
fi

# ============================================
# STEP 5: Configure Wine settings
# ============================================
echo -e "${BLUE}[5/7] Configuring Wine...${NC}"

export WINEPREFIX="$PREFIX_DIR/pfx"

# Virtual desktop (required for D3D8)
"$WINE_BIN" reg add "HKEY_CURRENT_USER\\Software\\Wine\\Explorer\\Desktops" /v "Default" /t REG_SZ /d "800x600" /f 2>/dev/null || true
"$WINE_BIN" reg add "HKEY_CURRENT_USER\\Software\\Wine\\Explorer" /v "Desktop" /t REG_SZ /d "Default" /f 2>/dev/null || true

# DLL override for d3d8to9
"$WINE_BIN" reg add "HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides" /v "d3d8" /t REG_SZ /d "native" /f 2>/dev/null || true

# WildTangent registry entries
"$WINE_BIN" reg add "HKEY_LOCAL_MACHINE\\SOFTWARE\\WildTangent\\InstalledSKUs\\WT011554" /v "ProductDisplayName" /t REG_SZ /d "Penguins!" /f 2>/dev/null || true
"$WINE_BIN" reg add "HKEY_LOCAL_MACHINE\\SOFTWARE\\WildTangent\\InstalledSKUs\\WT011554" /v "InstallDirectory" /t REG_SZ /d "$WINE_GAME_PATH" /f 2>/dev/null || true
"$WINE_BIN" reg add "HKEY_LOCAL_MACHINE\\SOFTWARE\\WildTangent\\InstalledSKUs\\WT011554" /v "HideBuyButton" /t REG_SZ /d "1" /f 2>/dev/null || true

echo -e "${GREEN}  ✓ Wine configured${NC}"

# ============================================
# STEP 6: Create launcher script
# ============================================
echo -e "${BLUE}[6/7] Creating launcher...${NC}"

cat > "$INSTALL_DIR/Penguins.sh" << 'LAUNCHER'
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
LAUNCHER

chmod +x "$INSTALL_DIR/Penguins.sh"
echo -e "${GREEN}  ✓ Launcher created${NC}"

# ============================================
# STEP 7: Add to Steam
# ============================================
echo -e "${BLUE}[7/7] Adding to Steam...${NC}"

# Find Steam user directory
STEAM_USERDATA="$STEAM_DIR/userdata"
STEAM_USER_ID=$(ls "$STEAM_USERDATA" 2>/dev/null | grep -E '^[0-9]+$' | grep -v '^0$' | head -1)
[ -z "$STEAM_USER_ID" ] && STEAM_USER_ID=$(ls "$STEAM_USERDATA" 2>/dev/null | grep -E '^[0-9]+$' | head -1)

if [ -n "$STEAM_USER_ID" ]; then
    SHORTCUTS_VDF="$STEAM_USERDATA/$STEAM_USER_ID/config/shortcuts.vdf"
    GRID_DIR="$STEAM_USERDATA/$STEAM_USER_ID/config/grid"
    mkdir -p "$GRID_DIR"

    # Generate app ID (matches shortcut generation below)
    APPID=$(python3 -c "
import hashlib
exe_path = '\"$INSTALL_DIR/Penguins.sh\"'
game_name = 'Penguins!'
appid = int(hashlib.md5((exe_path + game_name).encode()).hexdigest()[:8], 16)
appid = (appid & 0x7FFFFFFF) | 0x80000000
print(appid)
")

    # Install Pillow if needed (for artwork generation)
    python3 -c "from PIL import Image" 2>/dev/null || pip3 install --user --break-system-packages Pillow -q 2>/dev/null

    # Generate Steam artwork dynamically (works for any install path)
    python3 << ARTWORK_SCRIPT
import os
import shutil

grid_dir = "$GRID_DIR"
game_dir = "$INSTALL_DIR"
app_id = "$APPID"

title_path = f"{game_dir}/junk/local_assets/img/title.jpg"
logo_path = f"{game_dir}/help/logo.jpg"

try:
    from PIL import Image

    if os.path.exists(title_path):
        title = Image.open(title_path)
        logo = Image.open(logo_path) if os.path.exists(logo_path) else None

        # Grid/Cover (600x900 vertical)
        grid = Image.new('RGB', (600, 900), (30, 60, 90))
        scale = 600 / title.width
        title_scaled = title.resize((600, int(title.height * scale)), Image.LANCZOS)
        grid.paste(title_scaled, (0, 50))
        grid.save(f"{grid_dir}/{app_id}.png", "PNG")
        grid.save(f"{grid_dir}/{app_id}p.png", "PNG")

        # Hero banner (1920x620)
        hero = Image.new('RGB', (1920, 620), (20, 40, 60))
        scale = min(496 / title.height, 960 / title.width)
        title_hero = title.resize((int(title.width * scale), int(title.height * scale)), Image.LANCZOS)
        hero.paste(title_hero, ((1920 - title_hero.width) // 2, (620 - title_hero.height) // 2))
        hero.save(f"{grid_dir}/{app_id}_hero.png", "PNG")

        # Logo (transparent)
        if logo:
            logo_rgba = logo.convert('RGBA')
            data = list(logo_rgba.getdata())
            new_data = [(0,0,0,0) if (r<30 and g<30 and b<30) else (r,g,b,a) for r,g,b,a in data]
            logo_rgba.putdata(new_data)
            logo_rgba.save(f"{grid_dir}/{app_id}_logo.png", "PNG")

        print("Artwork generated with PIL")
    else:
        print("No source artwork found")

except ImportError:
    # Fallback: just copy title.jpg as grid image
    if os.path.exists(title_path):
        shutil.copy(title_path, f"{grid_dir}/{app_id}.jpg")
        shutil.copy(title_path, f"{grid_dir}/{app_id}p.jpg")
        print("Artwork copied (PIL not available)")
    else:
        print("No artwork (PIL not available)")
ARTWORK_SCRIPT
    echo -e "${CYAN}  Artwork installed${NC}"

    # Add to shortcuts.vdf using Python
    python3 << PYTHON_ADD
import os, struct, hashlib

shortcuts_file = "$SHORTCUTS_VDF"
game_name = "Penguins!"
exe_path = '"$INSTALL_DIR/Penguins.sh"'
start_dir = '"$INSTALL_DIR"'
launch_opts = "PROTON_USE_WINED3D=1 %command%"

def read_shortcuts(path):
    if not os.path.exists(path):
        return {}
    try:
        with open(path, 'rb') as f:
            data = f.read()
        shortcuts = {}
        pos = 0
        # Skip header
        if data[pos:pos+11] == b'\x00shortcuts\x00':
            pos = 11
        while pos < len(data) - 2:
            if data[pos:pos+1] != b'\x00':
                pos += 1
                continue
            pos += 1
            # Read index
            end = data.find(b'\x00', pos)
            if end == -1: break
            idx = data[pos:end].decode('utf-8', errors='ignore')
            pos = end + 1
            if not idx.isdigit(): continue
            # Read entry
            entry = {}
            while pos < len(data):
                t = data[pos:pos+1]
                if t == b'\x08':
                    pos += 1
                    break
                pos += 1
                end = data.find(b'\x00', pos)
                if end == -1: break
                key = data[pos:end].decode('utf-8', errors='ignore')
                pos = end + 1
                if t == b'\x01':  # string
                    end = data.find(b'\x00', pos)
                    entry[key] = data[pos:end].decode('utf-8', errors='ignore')
                    pos = end + 1
                elif t == b'\x02':  # int32
                    entry[key] = struct.unpack('<I', data[pos:pos+4])[0]
                    pos += 4
            shortcuts[int(idx)] = entry
        return shortcuts
    except:
        return {}

def write_shortcuts(path, shortcuts):
    with open(path, 'wb') as f:
        f.write(b'\x00shortcuts\x00')
        for idx in sorted(shortcuts.keys()):
            entry = shortcuts[idx]
            f.write(b'\x00' + str(idx).encode() + b'\x00')
            for k, v in entry.items():
                if isinstance(v, str):
                    f.write(b'\x01' + k.encode() + b'\x00' + v.encode() + b'\x00')
                elif isinstance(v, int):
                    f.write(b'\x02' + k.encode() + b'\x00' + struct.pack('<I', v))
            f.write(b'\x08')
        f.write(b'\x08\x08')

shortcuts = read_shortcuts(shortcuts_file)

# Check if exists
for e in shortcuts.values():
    if e.get('AppName') == game_name or e.get('appname') == game_name:
        print("Already in Steam")
        exit(0)

# Generate appid (md5 hash method for consistency)
appid = int(hashlib.md5((exe_path + game_name).encode()).hexdigest()[:8], 16)
appid = (appid & 0x7FFFFFFF) | 0x80000000

new_idx = max(shortcuts.keys(), default=-1) + 1
shortcuts[new_idx] = {
    'appid': appid,
    'AppName': game_name,
    'Exe': exe_path,
    'StartDir': start_dir,
    'icon': '"$INSTALL_DIR/Penguins.ico"',
    'ShortcutPath': '',
    'LaunchOptions': launch_opts,
    'IsHidden': 0,
    'AllowDesktopConfig': 1,
    'AllowOverlay': 1,
    'OpenVR': 0,
    'Devkit': 0,
    'LastPlayTime': 0,
}

# Backup and write
if os.path.exists(shortcuts_file):
    import shutil
    shutil.copy(shortcuts_file, shortcuts_file + '.bak')
os.makedirs(os.path.dirname(shortcuts_file), exist_ok=True)
write_shortcuts(shortcuts_file, shortcuts)
print("Added to Steam!")
PYTHON_ADD

    echo -e "${GREEN}  ✓ Added to Steam library${NC}"
    echo -e "${GREEN}  ✓ Artwork configured${NC}"
else
    echo -e "${YELLOW}  ⚠ Could not find Steam user - add game manually${NC}"
fi

# Create desktop shortcut
DESKTOP_FILE="$HOME/Desktop/Penguins.desktop"
cat > "$DESKTOP_FILE" << DESKTOP
[Desktop Entry]
Name=Penguins!
Comment=WildTangent Puzzle Game (2006)
Exec=$INSTALL_DIR/Penguins.sh
Icon=$INSTALL_DIR/Penguins.ico
Terminal=false
Type=Application
Categories=Game;
DESKTOP
chmod +x "$DESKTOP_FILE" 2>/dev/null || true
echo -e "${GREEN}  ✓ Desktop shortcut created${NC}"

# ============================================
# STEP 8: First run initialization
# ============================================
echo ""
echo -e "${BLUE}[8/8] Initializing game (first run)...${NC}"
echo -e "${YELLOW}  This creates all Steam paths and caches.${NC}"
echo -e "${YELLOW}  The game will launch briefly, then close automatically.${NC}"
echo ""

# Restart Steam to pick up shortcuts.vdf changes
STEAM_WAS_RUNNING=false
if pgrep -f "/usr/bin/steam" >/dev/null 2>&1 || pgrep -x "steam" >/dev/null 2>&1; then
    STEAM_WAS_RUNNING=true
    echo -e "${CYAN}  Restarting Steam to load new shortcut...${NC}"
    pkill -f "/usr/bin/steam" 2>/dev/null || pkill -x steam 2>/dev/null || true
    sleep 3
else
    echo -e "${CYAN}  Starting Steam to register shortcut...${NC}"
fi

# Start Steam with display
DISPLAY=:0 nohup steam &>/dev/null &

# Wait for Steam to fully start
echo -e "${CYAN}  Waiting for Steam to start...${NC}"
STEAM_STARTED=false
for i in {1..45}; do
    if pgrep -f "/usr/bin/steam" >/dev/null 2>&1 || pgrep -x "steam" >/dev/null 2>&1; then
        STEAM_STARTED=true
        sleep 5  # Give Steam extra time to fully initialize
        break
    fi
    sleep 1
done

if [ "$STEAM_STARTED" = false ]; then
    echo -e "${YELLOW}  Steam may not have started - you may need to restart it manually${NC}"
fi

# Find the game's Steam app ID from shortcuts
if [ -n "$STEAM_USER_ID" ]; then
    # Try to launch the game via Steam to initialize compatibility data
    echo -e "${CYAN}  Launching game to initialize Steam paths...${NC}"

    # Run the game directly first to create Proton paths
    export STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAM_DIR"
    export STEAM_COMPAT_DATA_PATH="$INSTALL_DIR/prefix"
    export PROTON_USE_WINED3D=1
    export WINEDLLOVERRIDES="d3d8=n"

    # Launch silently (run without display to create paths without showing window)
    echo -e "${CYAN}  Initializing game paths (no window will appear)...${NC}"

    # Run game briefly with no display - creates registry/paths but no visible window
    # Wine will error on display but paths are still initialized
    (
        unset DISPLAY
        timeout 10 "$PROTON" run 'C:\Program Files (x86)\WildGames\Penguins!\penguins.exe' &>/dev/null 2>&1
    ) &
    INIT_PID=$!

    # Show progress animation
    SPINNER="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    for i in {1..10}; do
        echo -ne "\r  ${CYAN}${SPINNER:$((i % 10)):1} Initializing...${NC}"
        sleep 1
    done
    echo -ne "\r                        \r"

    # Clean up any remaining processes
    kill $INIT_PID 2>/dev/null || true
    pkill -f "penguins.exe" 2>/dev/null || true
    pkill -9 wineserver 2>/dev/null || true

    sleep 2
    echo -e "${GREEN}  ✓ First run initialization complete${NC}"
else
    echo -e "${YELLOW}  ⚠ Skipped - run game manually once to initialize${NC}"
fi

# ============================================
# Done!
# ============================================
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              ✓ INSTALLATION COMPLETE! 🐧                      ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Game installed to:${NC} $INSTALL_DIR"
echo ""
echo -e "${YELLOW}▶ TO PLAY:${NC}"
echo "  • Game Mode (RECOMMENDED): Find 'Penguins!' in your Steam library"
echo "  • Desktop Mode: Double-click the desktop shortcut"
echo ""
echo -e "${YELLOW}▶ NOTE:${NC}"
echo "  The game shows a BLACK SCREEN for ~30-60 seconds on startup."
echo "  This is normal! Wait for the WildTangent logo to appear."
echo ""
echo -e "${YELLOW}▶ CONTROLLER SETUP (first time only):${NC}"
echo "  1. Select Penguins! in Game Mode"
echo "  2. Press Steam button → Controller Settings"
echo "  3. Choose 'Gamepad with Mouse Trackpad' template"
echo ""
echo -e "${YELLOW}▶ CONTROLS:${NC}"
echo "  Touch Screen → Tap to click"
echo "  Right Pad    → Mouse cursor"
echo "  R2 Trigger   → Left click"
echo ""
echo -e "${BLUE}Report bugs: https://github.com/deucebucket/penguins-steamdeck/issues${NC}"
echo ""
echo -e "${GREEN}Ready to play! Switch to Game Mode and have fun! 🐧${NC}"
