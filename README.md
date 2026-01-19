# Penguins! for Steam Deck

One-click installer for **Penguins!** (Wild Tangent, 2006) on Steam Deck.

Works in **Game Mode** with controller, trackpad, and touch screen!

## Quick Install

Open a terminal (Konsole) and run:

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
2. Extracts to `~/Games/Penguins/`
3. Creates a launcher script that works with Wine or Proton
4. Adds desktop shortcut

## Playing in Game Mode

After installing:

1. **Add to Steam**: Steam → Games → Add a Non-Steam Game
2. **Browse to**: `~/Games/Penguins/Penguins.sh`
3. **Set Controller Layout**: Use "Gamepad with Mouse Trackpad" or create custom

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

### Black screen
Press F to toggle fullscreen, or try windowed mode.

## Credits

- **Game**: Penguins! by Mumbo Jumbo / Wild Tangent (2006)
- **Archive**: [Internet Archive](https://archive.org/details/penguins2006)
- **Installer**: Made for Steam Deck community

## License

This installer script is public domain. The game itself is abandonware preserved by Archive.org.
