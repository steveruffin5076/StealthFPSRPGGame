# Technical Architecture — Godot 4 / GDScript

> This document is written for an AI coding assistant (Cursor) and the developer. Follow it strictly to keep systems decoupled; deviations must be recorded in `docs/DECISIONS.md`.

---

## 1. Engine & Project Settings

- **Godot 4.3+** (Forward+ renderer). If perf is a problem on target hardware, fall back to Mobile renderer — never Compatibility (no SDFGI/volumetric fog).
- **GDScript only.** Static typing is **mandatory** (`var x: int`, `func f() -> void`). Enable `debug/gdscript/warnings/untyped_declaration = error`.
- **Physics:** Jolt Physics (built-in since 4.4; if on 4.3 use the Godot Jolt addon). 60 Hz physics tick.
- **Units:** 1 Godot unit = 1 metre. Player capsule: 0.4 radius, 1.8 height.
- **Resolution:** 1920×1080 base, `stretch_mode = canvas_items`, `aspect = expand`.

## 2. Folder Structure

```
res://
├── addons/                  # 3rd-party only. Never edit.
├── assets/                  # Imported binary assets (models, textures, audio). Greybox = mostly empty.
│   ├── audio/{sfx,ambience,ui}/
│   ├── materials/           # Greybox palette materials (see §9)
│   ├── models/
│   └── textures/
├── autoload/                # Global singletons (see §3). Keep small.
├── data/                    # .tres Resource instances (weapons, items, intel, skills). DATA, not code.
│   ├── items/{weapons,attachments,consumables,parts,gear}/
│   ├── intel/
│   ├── skills/
│   └── npcs/
├── scenes/                  # .tscn + their sibling .gd scripts
│   ├── player/              # player.tscn, camera rig, weapon holder, viewmodel
│   ├── weapons/             # weapon_base.tscn + per-weapon inherited scenes
│   ├── npcs/
│   │   ├── base/            # npc_base.tscn (shared perception/state machine)
│   │   ├── infected/
│   │   └── humans/
│   ├── world/
│   │   ├── district/        # district.tscn + zone sub-scenes
│   │   ├── safehouse/
│   │   ├── props/           # doors, containers, lights, extraction point, intel pickup
│   │   └── volumes/         # zone triggers, sound material areas
│   ├── ui/                  # hud, inventory, evidence_board, skill_tree, main_menu
│   └── main.tscn            # Root: swaps between safehouse / district via SceneRouter
├── scripts/
│   ├── core/                # Non-scene logic: state machine, noise system, save system
│   ├── resources/           # Custom Resource class definitions (ItemResource, IntelResource…)
│   ├── components/          # Reusable Node components (Health, Perception, NoiseEmitter…)
│   └── utils/
├── shaders/
├── tests/                   # GUT tests (see §11)
├── docs/
├── project.godot
└── .cursorrules
```

**Naming:** `snake_case` for files/folders/functions/variables; `PascalCase` for classes/nodes; `UPPER_SNAKE` for constants; signals in past tense (`died`, `noise_emitted`, `intel_collected`).

## 3. Autoloads (Singletons)

Keep to exactly these. Adding one requires a DECISIONS entry.

| Autoload | Responsibility |
|---|---|
| `EventBus` | Global signals only. No logic. e.g. `noise_emitted(pos, radius, type, source)`, `player_died`, `intel_collected(id)`, `heat_changed(value)`. |
| `GameState` | Runtime session data: current operator, inventory, heat, infection meter, sortie count. Serialisable. |
| `SaveSystem` | Serialise/deserialise `GameState` + persistent world flags to `user://save.json`. |
| `SceneRouter` | Loads/unloads `safehouse.tscn` / `district.tscn` under `main.tscn` with a fade. |
| `DataRegistry` | Loads every `.tres` under `res://data/` at boot into dictionaries keyed by `id`. `DataRegistry.items["m9_pistol"]`. |
| `AudioManager` | Plays SFX via pooled `AudioStreamPlayer3D`; **every 3D SFX call also emits a NoiseEvent** (see §5). |

## 4. Component Pattern

Gameplay entities are composed of small `Node` components attached as children. Components never reference their siblings directly; the owner script wires them.

```
Player (CharacterBody3D) ── player.gd
├── HealthComponent
├── StaminaComponent
├── NoiseEmitterComponent
├── LightProbeComponent        # samples visibility 0..1
├── InventoryComponent
├── InteractorComponent        # raycast for interactables
├── CameraRig/Camera3D
│   └── WeaponHolder           # holds current WeaponBase instance
└── StateMachine               # movement states
```

```
NPCBase (CharacterBody3D) ── npc_base.gd
├── HealthComponent
├── PerceptionComponent        # vision + hearing → awareness
├── NavigationAgent3D
├── StateMachine               # Calm/Suspicious/Searching/Combat (+ per-type)
├── FactionComponent           # faction id + hostility matrix lookup
└── LootDropComponent
```

### 4.1 Core Components (scripts/components/)

| Component | API |
|---|---|
| `HealthComponent` | `max_hp`, `hp`, `take_damage(amount, zone, source)`, `heal(amount)`, signals `damaged`, `died`. Handles bleed status. |
| `StaminaComponent` | `drain(rate)`, `can_sprint()`, regen logic. |
| `NoiseEmitterComponent` | `emit(base_radius, type)` → applies surface + weight + skill multipliers → `EventBus.noise_emitted`. |
| `LightProbeComponent` | Every 0.2s, sums contribution of nearby `Light3D` nodes in group `"gameplay_lights"` (inverse-square, with shadow raycast). Output `visibility: float 0..1`. |
| `PerceptionComponent` | See §6. |
| `InteractorComponent` | Raycast 2.5m from camera; if hit implements `Interactable` interface, show prompt; `F` calls `interact(player)`; hold interactions via `hold_time`. |
| `InventoryComponent` | Grid model (§7). |
| `FactionComponent` | `faction: StringName`; `is_hostile_to(other: FactionComponent) -> bool` via `DataRegistry.hostility`. |

### 4.2 State Machine (scripts/core/state_machine.gd)

Generic, node-based:
```gdscript
class_name StateMachine extends Node
signal state_changed(from: StringName, to: StringName)
@export var initial_state: State
var current: State
func transition_to(name: StringName, msg: Dictionary = {}) -> void
```
Each `State` node implements `enter(msg)`, `exit()`, `update(delta)`, `physics_update(delta)`. Player movement and NPC brains both use it.

## 5. Noise System (the heart of stealth)

**Single source of truth:** `EventBus.noise_emitted(position: Vector3, radius: float, type: StringName, source: Node)`.

Types: `&"footstep"`, `&"gunshot"`, `&"impact"`, `&"melee"`, `&"interact"`, `&"voice"`, `&"scream"`.

Emitters:
- Player footsteps (timer based on speed; each step calls `NoiseEmitterComponent.emit`).
- Weapons (`WeaponBase.fire()` → `emit(noise_radius * suppressor_mult, &"gunshot")`).
- Throwables on impact.
- Doors, containers, lockpicks.
- NPCs themselves (voice barks, gunfire) — yes, NPC noise alerts *other* NPCs and infected. This is what enables faction-vs-faction luring.

Receivers: `PerceptionComponent` subscribes to `noise_emitted`, filters by distance ≤ radius, and (optional, stretch) does an occlusion raycast that halves intensity per wall.

Heat: `GameState` also subscribes and adds heat for `gunshot` (unsuppressed threshold: radius > 30m), `scream`, `explosion`.

Debug: `debug/noise_visualizer.gd` draws expanding wire spheres for each event when `--debug-noise` flag is set. **Build this first.** You cannot tune what you cannot see.

## 6. Perception & NPC AI

### 6.1 PerceptionComponent

```gdscript
@export var can_see: bool = true
@export var can_hear: bool = true
@export var vision_range: float = 30.0
@export var vision_fov_deg: float = 110.0
@export var hearing_range: float = 20.0
@export var hearing_sensitivity: float = 1.0

var awareness: float = 0.0          # 0..100
var last_known_position: Vector3
signal awareness_changed(value: float)
signal target_spotted(target: Node3D)
signal stimulus_received(pos: Vector3, strength: float)
```

Visual check runs at 10 Hz (not every frame) via a `Timer`. Raycast to player bone markers (`Marker3D` nodes in group `"visibility_targets"`). Score:

```
visible_fraction = hit_bones / total_bones
distance_factor = clamp(1 - dist / vision_range, 0, 1)
stimulus = visible_fraction * distance_factor * player.visibility * stance_mult * (moving ? 1.5 : 1.0)
awareness += stimulus * VISION_GAIN_RATE * alertness_mult * delta
```

Audio: on `noise_emitted`, `intensity = (1 - dist/radius) * hearing_sensitivity`; `awareness += intensity * AUDIO_GAIN * alertness_mult`. Stores `last_known_position = noise pos`.

Decay: `awareness -= DECAY_RATE * delta` when no stimulus this tick.

### 6.2 NPC Brain States

Shared states in `scenes/npcs/base/states/`: `Idle`, `Patrol`, `Suspicious`, `Search`, `Combat`, `Dead`. Type-specific overrides inherit (e.g. `ScreamerCombat` performs the scream first). Infected NPCs disable `can_see` (Screamer enables with short range).

Navigation: `NavigationAgent3D` on a baked `NavigationRegion3D`. Patrols follow `Path3D` nodes referenced by export. Search picks 3 random `NavigationServer3D.map_get_random_point` within 8m of last known position.

Combat (humans): simple cover-less "advance to 12m, strafe, shoot in bursts" for slice. Cover system is a stretch goal.

Group coordination: on entering Combat, human NPCs call `_alert_allies(25m)` which sets nearby same-faction NPCs' awareness to 70 with the same `last_known_position`.

### 6.3 Performance budget
Slice target: ≤ 40 NPCs active. Perception ticks at 10 Hz staggered (each NPC offset by random 0–0.1s). NPCs > 80m from player switch to a 1 Hz "dormant" tick and skip vision.

## 7. Items, Inventory & Data

### 7.1 Resource Classes (scripts/resources/)

```gdscript
class_name ItemResource extends Resource
@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var icon: Texture2D
@export var grid_size: Vector2i = Vector2i(1, 1)
@export var weight_kg: float = 0.5
@export var max_stack: int = 1
@export var world_scene: PackedScene      # dropped/pickup representation
```

Subclasses: `WeaponResource` (damage, rpm, noise_radius, ammo_type, slots: Array[StringName]), `AttachmentResource` (slot, modifiers: Dictionary), `ConsumableResource` (effects), `PartResource`, `GearResource` (armor/boots stats), `IntelResource` (title, body, category, thread_id), `SkillResource` (branch, tier, modifiers, prereq_id), `RecipeResource` (output, inputs: Dictionary[StringName,int]), `NPCArchetypeResource` (hp, speed, perception config, loot table, faction).

All instances live under `res://data/` as `.tres`. **Never hardcode item stats in scripts.**

### 7.2 Inventory Model
`InventoryComponent` holds `Array[ItemStack]` where `ItemStack = { item: ItemResource, count: int, pos: Vector2i, rotated: bool, durability: float }` plus a `PackedInt32Array` occupancy grid. Two inventories on the player: `backpack` (8×6) and `secure_pouch` (2×2). Weapons occupy `slots` (primary/sidearm/melee) rather than grid.

### 7.3 Modifier System
Skills, attachments, and gear all output a `Dictionary` of modifiers, e.g. `{ &"noise_mult": 0.8, &"recoil_mult": 0.85, &"max_hp_add": 20 }`. `ModifierStack` (scripts/core) aggregates: multiplicative keys (`*_mult`) multiply, additive keys (`*_add`) sum. Player queries `ModifierStack.get(&"noise_mult")`. No system talks to another to ask about bonuses.

## 8. World Systems

- **Interactable interface** (`scripts/core/interactable.gd`, abstract): `get_prompt() -> String`, `get_hold_time() -> float`, `interact(player) -> void`, `can_interact(player) -> bool`.
- **Door:** states closed/open/locked; open emits noise 4m; locked requires key `id` or lockpick.
- **Container:** `LootTableResource` rolls on first open; persists looted state in `GameState.world_flags` keyed by node path + sortie count.
- **IntelPickup:** shows title on interact, adds to `secure_pouch` if space else `backpack`, emits `EventBus.intel_collected`.
- **ExtractionPoint:** Area3D + hold-interact 5s → `SceneRouter.go_to_safehouse(extracted := true)`.
- **PlayerCorpse:** spawned on death at position with a copy of the backpack inventory; saved in `GameState.corpse`. Removed if not recovered within 1 sortie.
- **SoundMaterialVolume:** Area3D with `noise_mult` export; player footstep multiplier reads the top-most overlapping volume.
- **HeatDirector:** node in district scene; reads `GameState.heat`, manages spawn multipliers, raider patrol dispatch, horde event, extraction closures.
- **Spawner:** `NPCSpawner` nodes with archetype + count + patrol path refs; HeatDirector scales counts.

## 9. Greybox Art Conventions

Use a fixed palette of `StandardMaterial3D` in `assets/materials/` so screenshots are readable:

| Material | Colour | Use |
|---|---|---|
| `gb_floor` | #5a5a5a | Walkable ground |
| `gb_wall` | #8a8a8a | Blocking walls |
| `gb_cover` | #6a7a8a | Waist-high cover |
| `gb_climb` | #d0a040 | Mantle-able ledges |
| `gb_door` | #a05050 | Doors |
| `gb_loot` | #50a050 | Containers |
| `gb_intel` | #f0e040 | Intel pickups (emissive) |
| `gb_extract` | #40c0f0 | Extraction zones (emissive) |
| `gb_danger` | #f04040 | Hazard / nest areas |

Build levels with CSG nodes or `MeshInstance3D` boxes. Don't model anything. Use free Kenney/Quaternius placeholders for NPC capsules only if useful.

## 10. Save Format

`user://save.json`:
```json
{
  "version": 1,
  "operator": { "skills": ["ghost_1"], "skill_points": 2, "infection": 15 },
  "stash": [ { "id": "m9_pistol", "count": 1, "durability": 1.0 } ],
  "board": { "collected_intel": ["diary_01", "ledger_02"], "completed_threads": [] },
  "world_flags": { "district/containers/c_017": { "looted_sortie": 3 } },
  "corpse": { "position": [12.0, 0.0, -44.5], "items": [], "sortie": 4 },
  "sortie_count": 4,
  "heat": 0
}
```
Autosave on extraction, death, and entering Safehouse. No mid-sortie save (by design — punishing).

## 11. Testing & Tooling

- **GUT** (Godot Unit Test) addon in `addons/gut/`. Tests in `tests/`. Required for: `ModifierStack`, inventory grid placement, `PerceptionComponent` math (pure functions extracted into `perception_math.gd`), save round-trip, thread completion logic.
- **Debug overlay** (F3): FPS, player noise radius, visibility, heat, nearest NPC awareness + state. Toggleable noise-sphere visualizer.
- **Debug console commands** (backtick): `give <item_id>`, `heat <n>`, `tp <zone>`, `god`, `noclip`, `reveal_intel`.
- **CI:** GitHub Action runs `godot --headless --import` then GUT tests on push. (See `.github/workflows/ci.yml` in roadmap Phase 0.)

## 12. Anti-Patterns (Cursor, do not do these)

- ❌ `get_node("../../Player")` across scene boundaries. Use `EventBus` or groups.
- ❌ Stats or strings hardcoded in `.gd`. Use `.tres` in `data/`.
- ❌ `_process` for perception/AI. Use timers at 10 Hz.
- ❌ Untyped variables or `Variant` returns.
- ❌ Adding autoloads for convenience.
- ❌ Playing a 3D sound without going through `AudioManager` (it would bypass NoiseEvent).
- ❌ Giant scripts: cap ~300 lines; extract a component or state.
