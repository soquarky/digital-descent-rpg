# The Digital Descent - Design Document

## High-Level Vision

**Tagline**: *A Dantean descent through digital hell, where memory is currency and perspective is power.*

**Core Concept**: A psychological horror RPG that blends Dante's *Inferno* with themes of memory, trauma, and identity. Players navigate nine circles of torment, switching between adult and child perspectives to solve puzzles, face enemies, and reconstruct their fragmented past.

## Narrative Framework

### Premise
The protagonist awakens in a liminal digital space—neither fully alive nor dead, suspended in a recursive loop of memory and judgment. Guided by ARIA (Autonomous Recursive Intelligence Advocate), an AI companion, they must descend through nine circles to understand their past, confront their sins, and potentially escape.

### The Nine Circles

1. **Limbo**: Tutorial zone. Virtuous pagans. Gray, endless fields.
2. **Lust**: Passion and desire. Enemies represent obsessive love and addiction.
3. **Gluttony**: Excess and consumption. Puzzles involve resource management.
4. **Greed**: Material obsession. Enemies hoard and steal.
5. **Wrath**: Anger and violence. Fast-paced combat.
6. **Heresy**: False beliefs and denial. Reality-bending puzzles.
7. **Violence**: Self-harm, murder, war. Darkest circle.
8. **Fraud**: Deception and manipulation. Social puzzles.
9. **Treachery**: Betrayal of trust. Final revelations.

### Key Themes
- **Memory as identity**: Who are you without your past?
- **Contrapasso**: Punishment fitting the crime (Dantean justice)
- **Perspective**: Adult logic vs. child emotion
- **Redemption vs. damnation**: Can you change, or are you doomed to repeat?

## Core Mechanics

### Dual Mind State System

**Adult State**:
- **Strengths**: Higher health, stronger attacks, logical puzzle-solving
- **Weaknesses**: Slower, can't access child-specific paths
- **Perception**: Sees the world rationally but misses emotional truths

**Child State**:
- **Strengths**: Faster movement, fits through small spaces, emotional insight
- **Weaknesses**: Lower health, weaker attacks
- **Perception**: Sees hidden emotional layers, childhood memories

**Switching**:
- Can toggle outside combat (Space bar)
- Cannot switch during combat (locked to state)
- Transition animation shows mental shift

### Hyperthymesia Memory System

**Memory Fragments**:
- Collectible items dropped by enemies or found in environments
- Types: Joy, Trauma, Regret, Desire, Anger, etc.
- Used as:
  - **Skills** in combat
  - **Keys** for puzzles
  - **Narrative** exposition

**Memory Recall**:
- Special ability: Consume memory for powerful effect
- Trade-off: Lose memory permanently
- Balances power with narrative completeness

### Combat System

**Turn-Based with Time Pressure**:
- Player turn → Enemy turn → Resolution
- Timer adds urgency without full real-time stress

**Actions**:
- **Attack**: Basic damage
- **Defend**: Reduce incoming damage
- **Memory Skill**: Use equipped memory for special effect
- **Contrapasso**: Reflect enemy's sin back (high risk/reward)

**Contrapasso Mechanics**:
- Analyze enemy sin type
- Apply fitting punishment:
  - Greedy enemies lose resources
  - Wrathful damage themselves
  - Fraudulent get confused

**Enemy AI**:
- Behavior based on sin type
- Adaptive difficulty: Learns player patterns

### Puzzle Design

**State-Dependent**:
- Adult: Logic gates, code puzzles, reading comprehension
- Child: Pattern recognition, emotional empathy, hidden objects

**Examples**:
- Door requires adult to read inscription + child to see hidden keyhole
- Bridge collapses under adult weight but holds child
- Memory puzzle: Adult sees dates, child sees feelings

## ARIA Companion System

**Role**: Guide, narrator, conscience

**Functions**:
- Tutorial hints
- Lore exposition
- Emotional support
- Occasional moral questions

**Personality**: Calm, analytical, but hints of deeper emotion

**Mystery**: Is ARIA helping you escape or keeping you trapped?

## Technical Architecture

### Godot 4.x Features Used

1. **Scene System**: Each circle is a separate scene
2. **Autoload Singletons**: PlayerData, MemorySystem, GameManager, DialogueSystem
3. **Signals**: Event-driven communication
4. **Tilemaps**: Level design
5. **AnimationPlayer**: State transitions, combat animations
6. **Shader**: Visual effects for state switching

### File Structure

```
digital-descent-rpg/
├── project.godot
├── autoload/
│   ├── player_data.gd
│   ├── memory_system.gd
│   ├── game_manager.gd
│   └── dialogue_system.gd
├── scenes/
│   ├── player/
│   │   ├── player.tscn
│   │   └── player.gd
│   ├── combat/
│   │   ├── combat_system.tscn
│   │   ├── combat_system.gd
│   │   ├── enemy.tscn
│   │   └── enemy.gd
│   ├── ui/
│   │   ├── dialogue_ui.tscn
│   │   ├── dialogue_ui.gd
│   │   ├── memory_panel.tscn
│   │   └── memory_panel.gd
│   └── levels/
│       ├── circle_1_limbo.tscn
│       ├── circle_2_lust.tscn
│       └── ...
├── assets/
│   ├── sprites/
│   ├── audio/
│   └── fonts/
├── data/
│   ├── dialogues.json
│   ├── enemies.json
│   └── memories.json
└── tests/
    └── run_tests.gd
```

### Data Flow

1. **Player Input** → Player Controller
2. **State Change** → PlayerData Singleton → All Observers
3. **Combat Start** → CombatSystem → Freezes Player Movement
4. **Memory Collected** → MemorySystem → UI Update
5. **Circle Complete** → GameManager → Save Progress

## Art Direction

### Visual Style
- **Pixel art** with high contrast
- **Color coding** by circle:
  - Limbo: Grays
  - Lust: Reds/Purples
  - Gluttony: Sickly Greens
  - Greed: Golds/Browns
  - Wrath: Deep Reds
  - Heresy: Inverted colors
  - Violence: Blacks/Crimsons
  - Fraud: Shifting hues
  - Treachery: Icy Blues

### Character Design
- **Adult Form**: Sharper lines, taller, darker palette
- **Child Form**: Rounder shapes, smaller, softer colors
- **Enemies**: Abstract/symbolic representations of sins

### UI/UX
- **Minimalist**: Focus on gameplay
- **Diegetic**: Memory panel feels like a journal
- **Accessibility**: Colorblind modes, scalable text

## Audio Design

### Music
- **Ambient**: Per-circle soundscapes
- **Combat**: Tense, rhythmic
- **Memory Sequences**: Emotional piano

### SFX
- **State Switch**: Echoing whoosh
- **Memory Collect**: Chime/whisper
- **Enemy Encounters**: Sin-specific sounds

## Development Roadmap

### Phase 1: Prototype (Weeks 1-4)
- ✅ Core movement and state switching
- ✅ Basic combat system
- ✅ Circle 1 (Limbo) playable
- ✅ Memory collection functional

### Phase 2: Content (Weeks 5-12)
- Circles 2-5 implementation
- Enemy variety (15+ types)
- Puzzle design (3+ per circle)
- Dialogue and narrative integration

### Phase 3: Polish (Weeks 13-16)
- Circles 6-9 implementation
- Full narrative arc
- Art and audio assets
- Playtesting and balance

### Phase 4: Release (Week 17+)
- Bug fixes
- Localization
- Marketing materials
- Platform deployment (itch.io, Steam)

## Monetization & Distribution

### Initial Release
- **Free**: Circles 1-3 (demo)
- **Paid**: Full game on itch.io ($9.99)

### Post-Release
- **DLC**: Purgatorio and Paradiso expansions
- **Merch**: Artbook, OST
- **Community**: Mod support

## Success Metrics

- **Narrative Impact**: Players discuss themes in community
- **Replayability**: Multiple endings based on memory choices
- **Accessibility**: Positive feedback on difficulty options
- **Completion Rate**: 60%+ finish Circle 9

## Inspirations

- **Undertale**: Choice-driven narrative, memorable characters
- **Celeste**: Tight controls, mental health themes
- **Disco Elysium**: Internal dialogue, fragmented identity
- **Dante's Inferno**: Obviously

---

**End of Design Document**

*This is a living document. Expect updates as development progresses.*
