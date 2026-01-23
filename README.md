# Penguins! (2006 WildTangent) - Steam Deck Linux Port

## 🚧 WORK IN PROGRESS - NOT READY FOR GENERAL USE 🚧

This is an experimental port of the 2006 WildTangent game "Penguins!" to Linux/Steam Deck. **This is NOT a one-click installer yet!**

### Current Status: ALPHA

The game launches and gameplay works, but there are significant issues that need fixing before this is ready for general use.

---

## 🏆 Possibly the First Working Linux Port

No documented successful runs found on WineHQ AppDB, ProtonDB, or Linux forums. We may be the first to get this game partially working on Linux!

---

## 📸 Screenshots (Proof of Progress)

24 screenshots in `/screenshots/` documenting:
- Loading screen working
- Main menu accessible
- Options menu (game supports 1280x720 natively!)
- Level selection
- **8+ minutes of stable gameplay**

---

## ✅ What Works

- ✅ Game launches (DRM bypassed)
- ✅ Main menu loads
- ✅ Profile system
- ✅ Options menu
- ✅ Level selection
- ✅ In-game gameplay (penguins move, timer works)
- ✅ Sound/Music
- ✅ 8+ minutes stable gameplay tested

---

## ❌ What DOESN'T Work Yet

| Issue | Severity | Description |
|-------|----------|-------------|
| **Mouse offset** | 🔴 HIGH | In 720p mode, clicks don't align with where you click. Game area offset from mouse coordinates. |
| **Level completion crash** | 🔴 HIGH | Clicking "Next" after completing a level may crash the game. Needs investigation. |
| **Username input** | 🟡 MEDIUM | Cannot type username when creating profile. Steam keyboard doesn't work. Need config file workaround. |
| **Touch screen** | 🟡 MEDIUM | Touch coordinates offset, similar to mouse issue. |
| **Virtual desktop required** | 🟡 MEDIUM | Game runs in Wine virtual desktop window, not fullscreen. |

---

## 🔧 Current Technical Setup

### Requirements
- Proton 5.0
- d3d8to9 wrapper
- Wine virtual desktop mode
- Manual binary patches

### Binary Patches Required

The game executable must be patched to bypass WildTangent DRM:

```
Offset    Original           Patched              Purpose
0xec185   74 15 (je)         eb 15 (jmp)          Skip registry error
0xec408   0f 84 c1 00 00 00  90 90 90 90 90 90    Skip SKU check #1
0xec46b   7e 46 (jle)        90 90 (nop)          Skip SKU check #2
```

### Wine Settings Required

```bash
# Virtual desktop (required for D3D to work)
wine reg add "HKEY_CURRENT_USER\Software\Wine\Explorer\Desktops" /v "Default" /t REG_SZ /d "1280x720" /f
wine reg add "HKEY_CURRENT_USER\Software\Wine\Explorer" /v "Desktop" /t REG_SZ /d "Default" /f
```

### Launch Command

```bash
PROTON_USE_WINED3D=1 \
WINEDLLOVERRIDES="d3d8=n" \
STEAM_COMPAT_CLIENT_INSTALL_PATH="/home/deck/.steam/steam" \
STEAM_COMPAT_DATA_PATH="$PREFIX_PATH" \
"/path/to/Proton 5.0/proton" run penguins.exe
```

---

## 🎯 TODO List

- [ ] **Fix mouse/touch offset** - Critical for playability
- [ ] **Fix level completion crash** - Investigate "Next" button issue
- [ ] **Add username config** - Workaround for keyboard input
- [ ] **Test fullscreen mode** - May fix mouse offset
- [ ] **Create automated installer** - Currently manual process
- [ ] **Test more levels** - Only tested first zone
- [ ] **Package for distribution** - Not ready yet

---

## 📁 Files in This Repo

- `README.md` - This file
- `CHANGELOG.md` - Progress history
- `launch_penguins.sh` - Basic launcher (needs work)
- `screenshots/` - 24 proof-of-concept screenshots

**NOT included:**
- Game files (copyrighted)
- Wine prefix (too large)
- Patched executable (legal concerns)

---

## 🐧 About the Game

**Penguins!** (2006) by WildTangent - A puzzle game helping penguins escape through 80+ levels.

---

## 🙏 Credits

- Original game: WildTangent (2006)
- d3d8to9: [crosire](https://github.com/crosire/d3d8to9)
- Wine/Proton: Valve & Wine Project
- Port work: Claude Code + Steam Deck user

---

*Status: Alpha | Last updated: January 23, 2026*
