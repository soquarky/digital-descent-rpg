# Digital Descent RPG - Quick Start Guide

## What's New (Phase 1 Core Systems)

This version includes a complete foundation of **5 interconnected singleton systems** that handle all core game mechanics. Start here if you want to understand the architecture.

---

## Project Structure

```
digital-descent-rpg/
├─ autoload/                    # Singleton systems (auto-loaded by Godot)
│  ├─ player_data.gd          # State, health, memories, progression
│  ├─ memory_system.gd        # Skills, puzzles, consumption
│  ├─ combat_system.gd        # Turns, Contrapasso, enemies
│  ├─ dialogue_system.gd      # ARIA, dialogue trees, hints
│  └─ game_manager.gd         # Scene flow, progression, state
├─ scenes/
│  ├─ player/
│  │  ├─ player.tscn         # [TO CREATE]
│  │  └─ player.gd           # Movement + state switching
│  ├─ combat/                # [TO CREATE]
│  ├─ ui/                    # [TO CREATE]
│  ├─ levels/
│  │  ├─ circle_1_limbo.tscn
│  │  ├─ circle_2_lust.tscn
│  │  └─ ... (7 more circles)
│  └─ aria/                  # [TO CREATE]
├─ assets/
│  ├─ sprites/              # [TO ADD]
│  ├─ audio/                # [TO ADD]
│  └─ fonts/                # [TO ADD]
├─ data/
│  ├─ dialogues.json        # [TO CREATE]
│  ├─ enemies.json          # [TO CREATE]
│  └─ memories.json         # [TO CREATE]
├─ project.godot
├─ DESIGN_DOC.md
├─ IMPLEMENTATION_LOG.md     # [NEW]
└─ README.md
```

---

## How to Use the Core Systems

### 1. Player State Management

```gdscript
# Check current state
if PlayerData.is_adult_state():
    print("Logical perspective")
else:
    print("Emotional perspective")

# Toggle state (handled by player.gd, but you can trigger manually)
PlayerData.toggle_state()

# Health
PlayerData.take_damage(10)
PlayerData.heal(20)
```

### 2. Memory System

```gdscript
# Collect a memory
PlayerData.collect_memory("Fear of Loss", "trauma", 15)

# Use a skill
MemorySystem.use_skill("Sorrow Strike")

# Consume memory for powerful effect
MemorySystem.consume_memory_for_effect(0)  # Uses first memory

# Solve puzzle
MemorySystem.solve_puzzle("bridge_crossing")
```

### 3. Combat

```gdscript
# Spawn enemy
var enemy = CombatSystem.spawn_enemy("Siren of Desire")

# Start fight
CombatSystem.start_combat(enemy)

# Player action
CombatSystem.execute_player_action("attack")    # or "defend", "skill", "contrapasso"

# Enemy turn is automatic

# Check status
var status = CombatSystem.get_combat_status()
print(status["enemy_health_percent"])  # 0.0 - 1.0
```

### 4. Dialogue

```gdscript
# Start dialogue tree
DialogueSystem.start_dialogue("aria_welcome")

# Advance to next line
DialogueSystem.next_line()

# Select choice
DialogueSystem.select_choice(0)  # First choice

# Get ARIA commentary
var hint = DialogueSystem.get_aria_commentary("player_low_health")
```

### 5. Game Manager

```gdscript
# Start new game
GameManager.start_new_game()

# Load a specific circle
GameManager.load_circle(1)

# Complete current circle
GameManager.complete_circle(1)

# Check progression
var percent = GameManager.get_circle_completion_percentage()
print("Game completion: ", percent, "%")
```

---

## Signal Integration

All systems emit signals. Listen to them for UI updates:

```gdscript
# In any scene
func _ready():
    PlayerData.state_changed.connect(_on_state_changed)
    CombatSystem.combat_started.connect(_on_combat_started)
    MemorySystem.memory_skill_used.connect(_on_skill_used)
    DialogueSystem.dialogue_line_displayed.connect(_on_dialogue_line)

func _on_state_changed(new_state: String):
    # Update UI to show adult/child perspective
    pass
```

---

## What's Still Needed

### Immediate (Phase 2)
1. **Scene Files**: Create .tscn for player, 9 circles, combat UI, dialogue UI
2. **Sprite Assets**: Adult player, child player, 20+ enemy sprites
3. **Enemy Data**: Expand 6 core enemies to 20+ (JSON)
4. **Puzzles**: Design 30+ puzzles (3+ per circle)

### Short-term (Phase 2-3)
5. **Audio**: SFX for state switch, memory collection, combat
6. **Music**: 9 circle themes + menu/boss tracks
7. **UI**: Health bar, memory panel, dialogue box, progress tracker
8. **Animations**: State switch shader, walk cycle, attack/defense

### Testing & Balance (Phase 3-4)
9. **Difficulty Tuning**: Enemy stats, Contrapasso balance
10. **Playtesting**: Find bugs, gather feedback
11. **Accessibility**: Colorblind modes, font scaling, difficulty options

---

## Configuration

Edit these in their respective .gd files:

**Player Movement Speed**
```gdscript
# scenes/player/player.gd
const ADULT_SPEED = 150.0
const CHILD_SPEED = 200.0
```

**Combat Timing**
```gdscript
# autoload/combat_system.gd
turn_timer = 5.0   # seconds per player turn
turn_timer = 2.0   # seconds per enemy turn
```

**Health**
```gdscript
# autoload/player_data.gd
var max_health: int = 100
```

---

## Testing Your Setup

1. Open `project.godot` in Godot 4.x
2. Create a simple test scene that calls:
   ```gdscript
   func _ready():
       GameManager.start_new_game()
   ```
3. Run and check console for debug output
4. Verify signals fire (look at debugger)

---

## Next: Create Circle 1 (Limbo)

See `DESIGN_DOC.md` for Limbo design. The skeleton is ready—now populate it:

1. Create `scenes/levels/circle_1_limbo.tscn`
2. Add player instance
3. Add enemy spawner
4. Connect to GameManager signals
5. Add UI for health/memories

---

## Documentation

- **DESIGN_DOC.md**: Full game vision
- **IMPLEMENTATION_LOG.md**: Completed systems + roadmap
- **Code Comments**: In-line documentation in .gd files

---

**Current Version**: Phase 1 (Core Systems)
**Ready for**: Phase 2 (Content Creation)
