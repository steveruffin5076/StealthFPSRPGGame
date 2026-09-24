# Development Roadmap — Vertical Slice (12 weeks, solo)

> Each task is sized to be a single Cursor session (30–120 min). Task IDs (e.g. `P2-04`) are referenced in commits: `feat(P2-04): footstep noise emitter`.
> Each phase ends with a **Playtest Gate** — do not proceed until the gate criteria are met. Cut scope, not gates.

Weekly budget assumption: ~15–20 focused hours. If you have more, compress phases; do not add scope.

---

## Phase 0 — Foundation (Week 1)

**Goal:** A project Cursor can work in confidently. Nothing playable yet.

| ID | Task | Done when |
|---|---|---|
| P0-01 | Create Godot 4 project, apply settings from ARCHITECTURE §1 (typed GDScript warnings as errors, Jolt, 60Hz). | `project.godot` committed; opens clean. |
| P0-02 | Create folder structure (§2) with `.gdkeep` files. | Tree matches doc. |
| P0-03 | Autoloads: `EventBus`, `GameState`, `SceneRouter`, `DataRegistry`, `AudioManager`, `SaveSystem` as empty-but-typed shells with documented signals. | All registered; game boots to empty `main.tscn`. |
| P0-04 | Generic `StateMachine` + `State` classes. | GUT test transitions. |
| P0-05 | `ModifierStack` with GUT tests (mult/add aggregation). | Tests pass. |
| P0-06 | Install GUT; `tests/` runs headless via `godot --headless -s addons/gut/gut_cmdln.gd`. | One passing test. |
| P0-07 | GitHub Actions CI: import + run tests. | Green check on push. |
| P0-08 | Input map (GDD §11) in project settings. | All actions defined. |
| P0-09 | Greybox material palette (§9) as `.tres`. | 9 materials exist. |

**Gate 0:** CI green. Cursor can run tests from terminal.

---

## Phase 1 — Player & Movement (Week 2)

**Goal:** It feels good to sneak around a box room.

| ID | Task | Done when |
|---|---|---|
| P1-01 | `player.tscn`: CharacterBody3D, capsule, camera rig with head-bob-free smoothing, mouse look with sensitivity setting. | Can look around. |
| P1-02 | Movement StateMachine: Idle, Walk, Sprint, Crouch, Prone with GDD §5.1 speeds; capsule height changes; ceiling check blocks un-crouch. | Speeds match table ±5%. |
| P1-03 | `StaminaComponent`; sprint gated by stamina. | Drains/regens per spec. |
| P1-04 | Lean Q/E: camera offset ±0.5m with wall check. | Can peek corners. |
| P1-05 | Mantle: detect ledge ≤1.5m ahead, tween up. | Can climb `gb_climb` boxes. |
| P1-06 | `HealthComponent` with bleed status. | Debug key damages/bleeds. |
| P1-07 | `InteractorComponent` + `Interactable` interface + prompt UI. | Prompt appears on test cube. |
| P1-08 | Test level `scenes/world/test_arena.tscn`: rooms, ledges, cover, lit/dark areas. | Used for all Phase 1–3 tests. |
| P1-09 | Debug overlay (F3) skeleton: FPS, state, speed. | Toggles. |

**Gate 1:** 5 minutes of moving around the arena is not annoying. Crouch/lean/mantle are responsive. Commit a short GIF to `docs/media/`.

---

## Phase 2 — Noise, Light & Perception (Weeks 3–4) ⚠️ *Highest risk phase*

**Goal:** Stealth is legible. You know why you were spotted.

| ID | Task | Done when |
|---|---|---|
| P2-01 | `EventBus.noise_emitted` + `NoiseEmitterComponent` with surface/weight/skill multipliers. | Unit test on multiplier math. |
| P2-02 | **Noise visualizer** debug: expanding wire spheres per event. | Visible in arena. |
| P2-03 | Footstep emitter: timer by speed; `SoundMaterialVolume` overrides. | Gravel vs carpet visibly different spheres. |
| P2-04 | `LightProbeComponent` (§4.1) + "light gem" HUD. | Standing in shadow vs under lamp reads 0.1 vs 0.9. |
| P2-05 | `npc_base.tscn` with `PerceptionComponent` (hearing only first). | Dummy NPC turns toward noise. |
| P2-06 | Vision: bone markers on player, 10Hz raycasts, stimulus formula. | NPC awareness rises faster when lit & moving. |
| P2-07 | Awareness state thresholds + decay; `awareness_changed` → debug overlay shows nearest NPC awareness bar. | States transition per GDD §6.2. |
| P2-08 | Detection meter HUD (arc, white→orange→red). | Reads clearly. |
| P2-09 | NPC brain states: Idle, Patrol (Path3D), Suspicious (turn+bark placeholder), Search (3 points), Combat (move toward + placeholder "shoot" print), Dead. | Full loop observable. |
| P2-10 | NavigationRegion3D baked in arena; NPC pathing. | No stuck NPCs in 5-min test. |
| P2-11 | Tuning pass: `perception_config.tres` per archetype; expose all constants. | Can tune without code. |
| P2-12 | Perf: staggered 10Hz ticks, dormant mode >80m. | 40 NPCs at 60fps in arena. |

**Gate 2:** Blind playtester (friend) can explain *why* they got detected after each detection, 8/10 times. This is the make-or-break gate.

---

## Phase 3 — Combat & Weapons (Weeks 5–6)

**Goal:** Shooting is a tense, loud, last resort — and it works.

| ID | Task | Done when |
|---|---|---|
| P3-01 | `WeaponResource` + `weapon_base.tscn` (hitscan, damage falloff, hit zones, recoil pattern, ADS, spread). | M9 fires, damages NPC. |
| P3-02 | Weapon noise via `NoiseEmitterComponent` with suppressor multiplier; heat contribution. | Firing spawns big sphere; suppressed small. |
| P3-03 | Attachment system: slots on `WeaponResource`; `AttachmentResource` modifiers applied via `ModifierStack`. | Suppressor & red dot change behaviour. |
| P3-04 | Suppressor durability. | Degrades after 30 shots; noise grows. |
| P3-05 | Remaining weapons as `.tres` + inherited scenes: MP5, Hunting Rifle, Shotgun. | All fire per table. |
| P3-06 | Ammo types, magazines, reload (tactical vs empty). | Reload works; ammo counts. |
| P3-07 | Melee: knife swing, crowbar; **takedown** on unaware target from behind (2s, locks player). | Takedown kills Shambler/Raider silently. |
| P3-08 | Throwables: bottle arc, impact noise, distraction. | NPC investigates bottle. |
| P3-09 | Human NPC Combat state: advance to 12m, strafe, burst fire hitscan at player; `_alert_allies`. | Gets you killed if careless. |
| P3-10 | Death: player death screen → respawn hook (Safehouse comes Phase 5; for now restart arena). | Loop closes. |
| P3-11 | Weapon viewmodel placeholders (boxes) + basic sway/bob so it doesn't feel dead. | Acceptable. |
| P3-12 | Hit feedback: hitmarker, damage numbers off by default, NPC flinch. | Readable. |

**Gate 3:** A "go loud" arena run vs 6 raiders is winnable ~30% of the time. Stealth clearing the same room ~70%. Tune until that ratio holds.

---

## Phase 4 — Enemies & Factions (Week 7)

**Goal:** The district's inhabitants are distinct and interact.

| ID | Task | Done when |
|---|---|---|
| P4-01 | `NPCArchetypeResource` + `FactionComponent` + hostility matrix in `data/npcs/hostility.tres`. | Raider attacks Shambler. |
| P4-02 | Shambler: blind, 10m hearing, wander, swarm attack (melee, +15 infection). | Behaves per §8.1. |
| P4-03 | Listener: 25m hearing, stationary head-track, sprint to noise, front-takedown immune. | Terrifying. |
| P4-04 | Screamer: 8m vision, scream state (3s → +20 heat → summon 60m). | Kill-before-scream is a real moment. |
| P4-05 | Raider archetype: pistol/shotgun, campfire idle (`Idle` variant with chatter audio placeholder). | |
| P4-06 | Sentinel PMC: SMG, light armor, **flashlight cone** that raises player `visibility`, radio check-in every 45s (missed → Searching). | |
| P4-07 | Infection meter on player + Antiviral consumable. | Persists (temp) across arena restarts. |
| P4-08 | `LootDropComponent` + `LootTableResource`. | Corpses lootable. |
| P4-09 | Faction-vs-faction: NPC gunfire emits noise; infected converge on raiders. | Bottle lure → horde → raiders fight → player slips by. **Record this GIF.** |

**Gate 4:** The lure emergent scenario works reliably.

---

## Phase 5 — Safehouse, Inventory & Persistence (Week 8)

**Goal:** The loop has stakes.

| ID | Task | Done when |
|---|---|---|
| P5-01 | `InventoryComponent` grid model + GUT tests (placement, rotation, stacking). | Tests pass. |
| P5-02 | Inventory UI (Tab): drag/drop, rotate, secure pouch, weapon slots, weight display. | Usable with mouse. |
| P5-03 | `safehouse.tscn` greybox: stash, workbench, board wall, loadout locker, exit door. | |
| P5-04 | `SceneRouter`: Safehouse ⇄ District with fade; `ExtractionPoint` prop. | Full round-trip. |
| P5-05 | `SaveSystem` JSON per §10 + GUT round-trip test; autosave triggers. | Quit/relaunch keeps stash. |
| P5-06 | Death → `PlayerCorpse` spawn with backpack contents; respawn in Safehouse with starter kit; corpse persists 1 sortie. | Recovery works. |
| P5-07 | Container persistence (`world_flags`, 3-sortie refill). | |
| P5-08 | Loadout locker UI: choose from stash before departing. | |
| P5-09 | Workbench + `RecipeResource` + crafting UI. Recipes: Suppressor, Padded Boots, Bandage, Antiviral. Parts items. | Crafting works. |
| P5-10 | Heat system: `GameState.heat`, decay, `HeatDirector` node with spawn scaling, extraction closure, horde event. | Going loud spirals. |

**Gate 5:** Die with good loot and feel it. Extract with good loot and feel it.

---

## Phase 6 — Intel, Board & Skills (Week 9)

**Goal:** A reason to go back in.

| ID | Task | Done when |
|---|---|---|
| P6-01 | `IntelResource` + `IntelPickup` prop + reading UI (paper/screen overlay, doesn't pause). | |
| P6-02 | Write all 18 intel texts (`data/intel/*.tres`) per GDD §9.1/9.3 threads. Keep each ≤ 150 words. | Reviewed for tone. |
| P6-03 | Evidence Board UI: pinned cards, string connections per thread, thread completion popup + unlock. | |
| P6-04 | Thread unlocks: map annotation, Clinic back door flag, keycard hint, finale flag. | Each unlock visibly changes the district. |
| P6-05 | `SkillResource` + Skill Tree UI (3×5) + skill point award on intel bank; skills feed `ModifierStack`. | All 15 skills function. |
| P6-06 | Paper map item (M): static district image with annotation layer. | |
| P6-07 | Finale: data drive in Annex vault; extracting with it → ending text screen → credits → return to Safehouse in "post-game". | |

**Gate 6:** Full narrative loop completable using debug teleports.

---

## Phase 7 — The District (Weeks 10–11)

**Goal:** Build the actual level. This is the longest single task set.

| ID | Task | Done when |
|---|---|---|
| P7-01 | Blockout plan: top-down sketch of 300×300m district with zones, 3 extraction points, patrol routes, intel locations (`docs/media/district_plan.png`). | Reviewed against GDD §4.2. |
| P7-02 | Greybox Residential Blocks (verticality, fire escapes, 6 personal intel). | |
| P7-03 | Greybox Market Street (checkpoint, sightlines, vehicles as cover, 4 faction intel). | |
| P7-04 | Greybox Clinic (dark, tight, nest, Screamer, keycard, 4 medical intel). | |
| P7-05 | Greybox Corporate Annex (locked, PMC patrols, vault, 4 corporate intel). | |
| P7-06 | Safehouse ↔ district transition zone, 3 extraction points (1 randomly closed per sortie). | |
| P7-07 | Lighting pass: gameplay lights in `"gameplay_lights"` group; dark/dim/lit routes through every zone. Fixed dusk `WorldEnvironment`. | Every room has a dark route. |
| P7-08 | `SoundMaterialVolume` placement (glass, gravel, carpet, puddles). | |
| P7-09 | Spawners + patrol paths per zone; heat scaling counts. | |
| P7-10 | Container placement + loot tables tuned to ~40 rounds/sortie. | |
| P7-11 | Breakers / light switches in 3+ locations. | |
| P7-12 | Nav bake, collision audit, out-of-bounds kill volumes. | No escapes in 30-min test. |

**Gate 7:** Complete the slice yourself without debug tools in ≤ 6 sorties.

---

## Phase 8 — Polish & Playtest (Week 12)

| ID | Task | Done when |
|---|---|---|
| P8-01 | Audio placeholders: footsteps per surface, gunshots (suppressed/unsuppressed), infected idles, raider chatter, drone ambience, UI. Route via `AudioManager`. | |
| P8-02 | Barks system: NPC state changes trigger text/audio barks from a `BarkTableResource`. | |
| P8-03 | Main menu, pause, settings (sens, FOV, volume), quit. | |
| P8-04 | Onboarding: 5 diegetic notes in Safehouse + first-sortie hints. No tutorial level. | |
| P8-05 | Debug console commands (§11). | |
| P8-06 | 3 external playtests; log in `docs/PLAYTESTS.md`; fix top 5 issues each. | |
| P8-07 | Export Windows + Linux builds; itch.io private page. | |
| P8-08 | Write `docs/POSTMORTEM.md` and update backlog. | |

**Gate 8 (Slice Complete):** GDD §13 Definition of Done passes with an external tester.

---

## Risk Register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Perception feels random / unfair | High | Critical | Phase 2 gate; noise visualizer first; expose all constants. |
| Scope creep into "full game" | High | High | Backlog in GDD §14; every new idea goes there, not into the roadmap. |
| District blockout takes 2× longer | Medium | High | Build Residential first; slice can ship with 3 zones if Annex is cut (finale moves to Clinic). |
| Inventory UI eats a week | Medium | Medium | Ship with list-based inventory if grid UI isn't done by P5 end; grid model stays. |
| NPC navigation bugs in verticality | Medium | Medium | Keep infected ground-only; only player uses fire escapes. |
| Solo burnout | Medium | Critical | Gates force playable milestones every 1–2 weeks. Record GIFs. Share them. |

---

## Cutting Order (if behind schedule)

Cut in this order, never the reverse: Brute → Prone stance → Skill tree branches (keep Ghost) → Hunting Rifle → Corporate Annex (finale → Clinic) → Grid inventory UI (keep model) → Crafting (keep suppressor as loot) → Listener enemy.

**Never cut:** noise system, light probe, Shambler + Raider, one weapon + suppressor, takedown, extraction, death-loses-loot, intel + board (even with 8 items instead of 18).
