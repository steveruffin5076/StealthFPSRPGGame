# Blackout Protocol

Stealth tactical first-person RPG. A collapsed city, three years after a viral outbreak. You are an Operator: infiltrate, survive, scavenge, recover the truth — and get back out with it.

**Engine:** Godot 4.3+ · **Language:** GDScript · **Scope:** solo vertical slice (12 weeks) · **Art:** greybox

## Start here

| Doc | Purpose |
|---|---|
| [docs/01_GDD.md](docs/01_GDD.md) | Game design: pillars, loop, world, stealth model, combat, enemies, intel/narrative, death rules |
| [docs/02_ARCHITECTURE.md](docs/02_ARCHITECTURE.md) | Technical rules: folder layout, autoloads, components, noise system, AI, data, save format |
| [docs/03_ROADMAP.md](docs/03_ROADMAP.md) | 8 phases, ~80 Cursor-sized tasks with "Done when" criteria and playtest gates |
| [docs/04_CURSOR_PLAYBOOK.md](docs/04_CURSOR_PLAYBOOK.md) | Copy-paste prompts for driving Cursor through each task |
| [.cursorrules](.cursorrules) | Rules Cursor loads automatically |
| [docs/DECISIONS.md](docs/DECISIONS.md) · [docs/DEVLOG.md](docs/DEVLOG.md) · [docs/PLAYTESTS.md](docs/PLAYTESTS.md) | Living logs |

## What's already in the repo

- `project.godot` — settings, input map (GDD §11), collision layer names, 6 autoloads registered
- `autoload/` — `EventBus` (all global signals incl. `noise_emitted`), `GameState` (heat/infection/save dict), `SaveSystem`, `SceneRouter`, `DataRegistry`, `AudioManager` (3D SFX → NoiseEvent)
- `scripts/core/` — `StateMachine`/`State`, `ModifierStack`, `Interactable`
- `scripts/resources/` — all custom Resource classes (items, weapons, attachments, intel, skills, recipes, NPC archetypes)
- `assets/materials/` — greybox palette
- `tests/` — GUT tests for `ModifierStack` and save round-trip
- `.github/workflows/ci.yml` — headless import + tests

## First steps

1. Install Godot 4.3+ and open `project.godot`. Let it import.
2. Install GUT (AssetLib → "GUT") into `addons/gut/` (roadmap **P0-06**). Run tests: `godot --headless -s addons/gut/gut_cmdln.gd -gexit`
3. Open the repo in Cursor. Begin with the kick-off prompt in `docs/04_CURSOR_PLAYBOOK.md` for task **P0-04** onward (P0-01/02/03/05/08/09 are done).

## Design pillars

1. **Silence is survival** — sound is the primary detection channel.
2. **Every bullet is a decision** — ammo scarce, gunfire loud, suppressors degrade.
3. **Return or lose it** — loot is only real once banked; death drops everything.
4. **The city tells the story** — no cutscenes; 18 intel pickups, an evidence board.
5. **Quiet dread** — slow, atmospheric, vulnerable.
