# Penguins! for Steam Deck

One-click installer for **Penguins!** (Wild Tangent, 2006) on Steam Deck.

Works in **Game Mode** with controller, trackpad, and touch screen!

## Quick Install

Open a terminal (Konsole) in Desktop Mode and run:

```bash
curl -sL https://raw.githubusercontent.com/deucebucket/penguins-steamdeck/main/install.sh | bash
```

Or clone and run:

```bash
git clone https://github.com/deucebucket/penguins-steamdeck.git
cd penguins-steamdeck
./install.sh
```

## What It Does

1. Downloads Penguins! from [Archive.org](https://archive.org/details/penguins2006)
2. Installs Visual C++ 2005 Runtime (required for WildTangent games)
3. Sets up WildTangent registry keys
4. Configures 1280x800 resolution for Steam Deck
5. Creates a Proton-compatible launcher with display fixes
6. **Automatically adds to Steam** - no manual setup needed!

## Playing

After installing:

1. **Switch to Game Mode** (or restart Steam in Desktop Mode)
2. **Find "Penguins!"** in your Steam library
3. **Play!** Use touch screen for best experience

> **Note:** The game works best in **Game Mode**. Desktop Mode (Wayland) may have display issues with this old DirectX 8 game.

### Recommended Controller Mapping

| Control | Action |
|---------|--------|
| Right Trackpad | Mouse cursor |
| R2 (Right Trigger) | Left click - Drag gadgets |
| L2 (Left Trigger) | Right click - Rotate bridges |
| Y | Fullscreen (F) |
| Start | Pause menu (P) |
| X | Reset level (R) |
| B | Help (H) |
| Touch Screen | Tap and drag - Works great! |

## Game Controls

Penguins! is a puzzle game where you drag gadgets to help penguins escape:

- **Mouse/Touch**: Drag gadgets from the tray to the level
- **Right-click/L2**: Rotate bridges and some gadgets
- **F**: Toggle fullscreen
- **P**: Pause
- **R**: Reset level
- **H**: Show hints

## Requirements

- Steam Deck (or Linux with Wine)
- **Proton Experimental** installed from Steam (if no system Wine)

## Troubleshooting

### "No Wine/Proton found"
Install Proton Experimental from Steam:
- Steam → Library → Search "Proton" → Install "Proton Experimental"

### Game doesn't launch
Try running from terminal to see errors:
```bash
~/Games/Penguins/Penguins.sh
```

### Invisible window / No display in Desktop Mode
This is a known issue with old DirectX 8 games on Wayland (KDE Plasma).
**Solution:** Switch to Game Mode - GameScope handles this properly.

### Runtime error
The installer automatically installs VC++ 2005 Runtime. If you still get errors:
```bash
# Reinstall the game
rm -rf ~/Games/Penguins
./install.sh
```

## Credits

- **Game**: Penguins! by Mumbo Jumbo / Wild Tangent (2006)
- **Archive**: [Internet Archive](https://archive.org/details/penguins2006)
- **Installer**: Made for Steam Deck community

## License

This installer script is public domain. The game itself is abandonware preserved by Archive.org.
