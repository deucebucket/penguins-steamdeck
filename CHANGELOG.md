# Changelog - Penguins! Steam Deck Port

## [2.6.0] - 2026-01-28 - NEW SINGLE-WINDOW MANAGER + PROFILE EDITOR

### Added
- **PenguinsManager.py** - Complete rewrite as single-window tkinter GUI
  - Clean two-panel layout (800x480, fits Steam Deck perfectly)
  - **Real profile creation** - Creates actual game profiles instantly
  - **Profile editing** - Rename, Copy, Reset, Delete profiles
  - Reads actual usernames from save files
  - Visual profile cards with status indicators
  - No more "pending" workarounds - profiles work immediately
- Profile binary format reverse-engineered for username read/write

### Changed
- Replaced multi-dialog kdialog mess with single window
- Profile slots now show actual in-game usernames
- Dark theme with cyan accents
- Credit "by deucebucket" added to manager

### Technical
- Username stored at pattern `05 04 00 <len> <name>` in profile.dat
- Profiles created by copying default_profile.dat template
- File permissions set to 755 to match game expectations

---

## [2.5.0] - 2026-01-27 - GAME MANAGER + USER PROFILES

### Added
- **PenguinsManager.sh** - Full game management tool with kdialog GUI
  - Launch Game
  - Manage Users (up to 4 profiles)
  - Check for Updates (git-based)
  - Repair/Reinstall (preserves profiles)
- Text input helper scripts (steam_text_input.sh, username_setup.sh)
- Default profile included in installer

### Changed
- Simplified launcher (removed broken splash screen approach)
- Install.sh now installs manager alongside game

---

## [2.4.0] - 2026-01-27 - LEVEL TRANSITION CRASH FIXED!

### Fixed
- **CRITICAL: Level transition crash FIXED!** All levels now playable!
- Root cause identified: Wine's Gecko/mshtml has use-after-free bugs
- Solution: Disable Gecko via `WINEDLLOVERRIDES="d3d8=n;mshtml=;gecko="`

### Technical Analysis
The WildTangent engine embeds Mozilla Gecko (XUL) for UI rendering. When transitioning between levels, Wine's implementation triggers:
1. Null pointer write in XUL at RVA 0x60a31
2. Use-after-free in ole32.dll at 0x6521c009 (COM vtable call on freed object)

Disabling Gecko prevents these crashes without affecting gameplay - the game doesn't actually need web rendering.

### Changed
- Simplified launcher script (removed verbose debug logging)
- Updated install.sh with crash fix
- Updated README to reflect fully playable status

---

## [0.2.0] - 2026-01-23 - GAMEPLAY VERIFIED

### Added
- 24 screenshots documenting full gameplay session
- Options menu accessible (sound, resolution settings)
- Profile system works (save/load)
- Level selection screen functional
- Full gameplay tested for 8+ minutes continuously

### Working Features
- Game loads without Runtime Error (DRM bypassed)
- Main menu fully functional
- Profile creation/selection
- Options menu (1280x720 resolution confirmed!)
- Level preview and selection
- In-game controls: SKIP, RESET, HINT, MENU
- Penguin animations and movement
- Game tools (items) selectable
- Timer working

### Known Issues
- **Mouse offset in 720p mode** - Clicks don't align properly with visual elements
- Level completion "Next" button crash - needs more testing
- Username input - Steam keyboard not working
- Touch screen alignment - off by some pixels

### Technical Details
- Proton 5.0 with PROTON_USE_WINED3D=1
- d3d8to9 wrapper (native d3d8 override)
- Wine virtual desktop mode required for D3D enumeration
- Game natively supports 1280x720 resolution

---

## [0.1.0] - 2026-01-23 - FIRST SUCCESSFUL LAUNCH

### Added
- Binary patches to bypass WildTangent DRM
  - 0xec185: je → jmp (skip registry error)
  - 0xec408: jz → NOP (skip SKU check 1)
  - 0xec46b: jle → NOP (skip SKU check 2)
- d3d8to9 wrapper for DirectX 8 compatibility
- Wine virtual desktop configuration (800x600 → 1280x720)
- WildTangent registry entries for SKU info

### Fixed
- "Runtime Error! Application requested termination" - FIXED
- "Could not find compatible Direct3D devices" - FIXED

### First Achievements
- Game renders graphics correctly
- Main menu accessible
- This may be the FIRST documented working Linux/Wine/Steam Deck port!
  - WineHQ AppDB: No entry for Penguins!
  - ProtonDB: No reports found
  - Linux forums: Only reports of failures
