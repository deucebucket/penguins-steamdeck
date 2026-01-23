# Changelog - Penguins! Steam Deck Port

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
