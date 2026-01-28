#!/bin/bash
# =============================================
# Penguins! Game Manager
# =============================================
# One-click tool for: Install, Update, User Management
# Run from Desktop Mode or add to Steam as non-Steam game

GAME_DIR="$(cd "$(dirname "$0")" && pwd)"
PROFILE_DIR="$GAME_DIR/prefix/pfx/drive_c/ProgramData/WildTangent/penguins/Persistent/resources/profiles"
REPO_URL="https://github.com/deucebucket/penguins-steamdeck"

# Ensure we have a display
export DISPLAY="${DISPLAY:-:0}"

# ============================================
# MENU FUNCTIONS
# ============================================

show_menu() {
    CHOICE=$(kdialog --menu "Penguins! Game Manager" \
        "launch" "🎮 Launch Game" \
        "users" "👤 Manage Users (Profiles)" \
        "update" "⬇️ Check for Updates" \
        "install" "📦 Repair/Reinstall" \
        "exit" "❌ Exit" \
        --title "Penguins! Manager" \
        2>/dev/null)

    case "$CHOICE" in
        launch) launch_game ;;
        users) manage_users ;;
        update) check_update ;;
        install) repair_install ;;
        exit|"") exit 0 ;;
    esac

    # Return to menu after action
    show_menu
}

# ============================================
# LAUNCH GAME
# ============================================

launch_game() {
    kdialog --passivepopup "Launching Penguins!...\nPlease wait 30-60 seconds." 5 2>/dev/null
    exec "$GAME_DIR/Penguins.sh"
}

# ============================================
# USER/PROFILE MANAGEMENT
# ============================================

manage_users() {
    mkdir -p "$PROFILE_DIR"

    # List existing profiles
    PROFILES=""
    for i in 0 1 2 3; do
        if [ -f "$PROFILE_DIR/profile$i.dat" ]; then
            PROFILES="$PROFILES profile$i \"Profile $((i+1)) (exists)\""
        else
            PROFILES="$PROFILES profile$i \"Profile $((i+1)) (empty)\""
        fi
    done

    USER_CHOICE=$(eval kdialog --menu \"Select a profile to manage:\" $PROFILES \
        --title \"User Profiles\" 2>/dev/null)

    [ -z "$USER_CHOICE" ] && return

    PROFILE_NUM="${USER_CHOICE#profile}"
    PROFILE_FILE="$PROFILE_DIR/profile$PROFILE_NUM.dat"

    if [ -f "$PROFILE_FILE" ]; then
        # Profile exists - offer to delete or keep
        ACTION=$(kdialog --menu "Profile $((PROFILE_NUM+1)) exists" \
            "keep" "Keep this profile" \
            "delete" "Delete this profile" \
            "setname" "Change username (new game)" \
            2>/dev/null)

        case "$ACTION" in
            delete)
                rm -f "$PROFILE_FILE"
                kdialog --passivepopup "Profile $((PROFILE_NUM+1)) deleted" 3 2>/dev/null
                ;;
            setname)
                setup_new_profile "$PROFILE_NUM"
                ;;
        esac
    else
        # New profile
        setup_new_profile "$PROFILE_NUM"
    fi
}

setup_new_profile() {
    local NUM="$1"

    USERNAME=$(kdialog --inputbox "Enter username for Profile $((NUM+1)):" "Player$((NUM+1))" \
        --title "New Profile" 2>/dev/null)

    if [ -n "$USERNAME" ]; then
        # Store username for the game to pick up
        # The game will create the actual profile on first run
        echo "$USERNAME" > "$GAME_DIR/.pending_username_$NUM"
        kdialog --passivepopup "Username '$USERNAME' set for Profile $((NUM+1))\nStart the game to activate." 5 2>/dev/null
    fi
}

# ============================================
# UPDATE CHECK
# ============================================

check_update() {
    kdialog --passivepopup "Checking for updates..." 2 2>/dev/null

    cd "$GAME_DIR"

    if [ -d ".git" ]; then
        git fetch origin 2>/dev/null
        LOCAL=$(git rev-parse HEAD 2>/dev/null)
        REMOTE=$(git rev-parse origin/main 2>/dev/null)

        if [ "$LOCAL" != "$REMOTE" ]; then
            if kdialog --yesno "Update available!\n\nDownload and install update?" --title "Update Available" 2>/dev/null; then
                git pull origin main 2>/dev/null
                kdialog --passivepopup "Update complete! Restart the manager." 5 2>/dev/null
            fi
        else
            kdialog --passivepopup "You have the latest version!" 3 2>/dev/null
        fi
    else
        kdialog --sorry "Update check requires git repository.\nReinstall from GitHub to enable updates." 2>/dev/null
    fi
}

# ============================================
# REPAIR/REINSTALL
# ============================================

repair_install() {
    if kdialog --yesno "This will reset the game prefix.\nYour profiles will be preserved.\n\nContinue?" --title "Repair Install" 2>/dev/null; then

        # Backup profiles
        if [ -d "$PROFILE_DIR" ]; then
            mkdir -p "$GAME_DIR/profile_backup"
            cp "$PROFILE_DIR"/*.dat "$GAME_DIR/profile_backup/" 2>/dev/null
        fi

        # Reset prefix
        rm -rf "$GAME_DIR/prefix"
        cp -a "$GAME_DIR/prefix_template" "$GAME_DIR/prefix"

        # Restore profiles
        if [ -d "$GAME_DIR/profile_backup" ]; then
            mkdir -p "$PROFILE_DIR"
            cp "$GAME_DIR/profile_backup"/*.dat "$PROFILE_DIR/" 2>/dev/null
            rm -rf "$GAME_DIR/profile_backup"
        fi

        kdialog --passivepopup "Repair complete!" 3 2>/dev/null
    fi
}

# ============================================
# MAIN
# ============================================

# Check if kdialog is available
if ! which kdialog >/dev/null 2>&1; then
    echo "Error: kdialog not found. Run in Desktop Mode with KDE."
    exit 1
fi

show_menu
