# Digital Descent - Quick Start Guide

## Overview
*The Digital Descent* is a Dantean psychological horror RPG where you navigate nine circles of torment, switching between adult and child perspectives to solve puzzles and face your memories.

## Getting Started

### Option 1: GitHub Codespaces (Recommended for Editing)
1. Click **Code → Codespaces → Create codespace**
2. Wait for environment setup (~3 minutes)
3. Edit GDScript files in browser
4. Changes auto-sync to repository

### Option 2: Desktop Development
1. **Clone the repository**:
   ```bash
   git clone https://github.com/soquarky/digital-descent-rpg.git
   cd digital-descent-rpg
   ```

2. **Install Godot 4.2+**: Download from [godotengine.org](https://godotengine.org/download)

3. **Open project**: 
   - Launch Godot
   - Click "Import"
   - Select `project.godot`

4. **Run the game**: Press F5 or click the Play button

## Core Gameplay

### Controls
- **WASD/Arrows**: Move
- **Space**: Switch mind state (Adult ↔ Child)
- **E**: Interact
- **Q**: Recall memory (special ability)
- **ESC**: Pause menu

### Mind States
**Adult Form**:
- Higher health and damage
- Can read complex texts
- Access adult memories
- Sees rational solutions

**Child Form**:
- Faster movement
- Can fit through small spaces
- Access childhood memories
- Sees emotional truths

### Combat System
- **Turn-based** with time pressure
- **Contrapasso mechanics**: Reflect enemies' sins back at them
- **Memory skills**: Use collected memories as abilities
- State-dependent strengths

### Memory Fragments
Collect to:
- Unlock abilities
- Reveal backstory
- Solve puzzles
- Progress through circles

## Project Structure

```
digital-descent-rpg/
├── autoload/              # Global systems
│   ├── player_data.gd     # Player state management
│   ├── memory_system.gd   # Memory collection
│   ├── game_manager.gd    # Game state
│   └── dialogue_system.gd # Conversations
├── scenes/
│   ├── player/           # Player controller
│   ├── combat/           # Combat system
│   ├── ui/               # User interface
│   └── levels/           # 9 circles
├── assets/               # Art, audio, etc.
└── docs/                 # Full documentation
```

## Development Workflow

### Codespaces → Desktop
1. **Edit in Codespaces**: Make code changes in browser
2. **Commit changes**: Git automatically tracks
3. **Pull to desktop**: 
   ```bash
   git pull origin main
   ```
4. **Test in Godot**: Open and run on desktop
5. **Push updates**:
   ```bash
   git add .
   git commit -m "Your changes"
   git push
   ```

### Adding New Content

**New Enemy**:
1. Duplicate `scenes/combat/enemy.tscn`
2. Set `sin_type` export variable
3. Customize stats and appearance

**New Circle**:
1. Duplicate `scenes/levels/circle_1_limbo.tscn`
2. Update `circle_number`
3. Design level layout
4. Add enemies and memory fragments

**New Memory Type**:
1. Add to `memory_system.gd` → `MemoryType` enum
2. Implement effect in combat or puzzles

## Testing

### Local Testing
```bash
# Run all tests
godot --headless --script tests/run_tests.gd

# Run specific test
godot --headless --script tests/test_combat.gd
```

### CI/CD
- Automatic builds on push to `main`
- Exports: Linux, Windows, Web
- Artifacts available in Actions tab

## Common Issues

**Codespaces slow?**
- Use 4-core machine type (Settings → Machine type)

**Godot won't open project?**
- Ensure Godot version is 4.2+
- Check `project.godot` exists

**Git conflicts?**
```bash
git fetch origin
git reset --hard origin/main
```

## Next Steps

1. **Read [DESIGN_DOC.md](./DESIGN_DOC.md)** for full game design
2. **Play through Circle 1** to understand mechanics
3. **Join discussions** in Issues tab
4. **Contribute** via Pull Requests

## Resources

- [Godot Documentation](https://docs.godotengine.org/)
- [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [Project Discord](#) (coming soon)

---

**Ready to descend?** Start with `scenes/levels/circle_1_limbo.tscn` and explore! 🔥
