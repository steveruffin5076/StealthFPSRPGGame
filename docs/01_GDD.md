# BLACKOUT PROTOCOL — Game Design Document (Vertical Slice)

> Working title. Stealth Tactical First-Person RPG set in a collapsed city after a viral outbreak.
> Target: Godot 4.3+, GDScript, solo developer, 1–3 month vertical slice, greybox art.

---

## 1. High Concept

You are an **Operator** — one of the last trained infiltrators sent into a quarantined city years after the outbreak collapsed it. Nobody is coming to rescue anyone. Your job is to **live**, **learn**, and **leave with the truth**.

From a fortified **Safehouse**, you make sorties into the city district. You move quietly, avoid or eliminate threats, scavenge parts and ammunition, and recover **Intel** — documents, hard drives, recordings — that piece together what the virus is and who released it. Everything you carry is at risk until you make it back. Everything you bank in the Safehouse is permanent.

**One-line pitch:** *Thief meets Escape from Tarkov in a dead city, told through the paper trail of the people who killed it.*

## 2. Design Pillars

| Pillar | What it means in practice |
|---|---|
| **Silence is survival** | Sound is the primary detection vector. Every action has a noise value. Infected hear; humans hear *and* see. |
| **Every bullet is a decision** | Ammo is scarce and loud. Suppressors degrade. Melee is quiet but risky. The best fight is the one you avoided. |
| **Return or lose it** | Loot and intel are only "real" once banked at the Safehouse. Death drops everything on your body. |
| **The city tells the story** | No cutscenes. Intel pickups, environmental scenes, and audio logs reveal the outbreak's history. |
| **Quiet dread, not jump scares** | Slow pacing, oppressive atmosphere, readable but tense threats. Horror comes from vulnerability, not gore. |

## 3. Core Loop

```
SAFEHOUSE                          THE DISTRICT                          SAFEHOUSE
┌──────────────┐    depart    ┌─────────────────────┐    extract    ┌──────────────┐
│ Plan sortie  │ ──────────▶  │ Infiltrate          │ ───────────▶ │ Bank loot    │
│ Pick loadout │              │ Observe / Avoid     │              │ Read intel   │
│ Craft/Repair │              │ Scavenge parts/ammo │              │ Upgrade gear │
│ Read board   │              │ Recover intel       │              │ Spend skill  │
└──────────────┘              │ Escape or die       │              └──────────────┘
                              └─────────────────────┘
                                        │ death
                                        ▼
                              Body + all carried loot
                              stays in world (1 recovery
                              attempt; then despawns)
```

**Session length target:** 15–30 minutes per sortie. 3–5 sorties to complete the vertical slice's intel board.

## 4. World & Setting

### 4.1 Backstory (for the developer; the player learns this through intel)
- **Year 0:** A respiratory virus (codename **HALCYON-7**) leaks from a private biotech research facility in the city. Officially a "natural zoonotic event."
- **Year 0–1:** Quarantine, then collapse. Government abandons the city. Military cordon becomes permanent.
- **Year 3 (now):** The player is sent in by an unnamed handler. Their stated mission: recover research data. Their real question: *was this an accident?*

### 4.2 The District (vertical slice map)
A single greybox district approx. **300m × 300m**, hand-built, with these zones:

| Zone | Description | Primary threat | Intel |
|---|---|---|---|
| **Safehouse** (edge) | Fortified parking structure basement. Hub. No threats. | None | Evidence board |
| **Residential Blocks** | Apartments, alleys, courtyards. Verticality via fire escapes. | Infected (Shamblers, Listeners) | Personal diaries, phones |
| **Market Street** | Long sightlines, burned-out vehicles, a raider checkpoint. | Raiders (human faction) | Raider ledgers, radio logs |
| **Clinic** | Field hospital turned nest. Dark, tight corridors. | Infected (dense), 1 Screamer | Medical records, triage notes |
| **Corporate Annex** | Locked biotech satellite office. Requires keycard from Clinic. | Sentinel PMC (elite human) | HALCYON-7 research data (finale) |
| **Extraction Points** (×3) | Sewer grate, rooftop zipline, back-alley gate. One is always randomized closed. | — | — |

### 4.3 Time of Day
Static "permanent dusk" for the slice (simplifies lighting and AI vision). Day/night cycle is a post-slice stretch goal.

## 5. Player

### 5.1 Movement
| State | Speed (m/s) | Noise radius (m) | Notes |
|---|---|---|---|
| Crouch-walk | 1.5 | 2 | Default stealth speed |
| Walk | 3.0 | 6 | |
| Sprint | 5.5 | 14 | Consumes stamina |
| Prone | 0.8 | 1 | Cannot fire rifles while moving |
| Lean (Q/E) | — | 0 | Peek corners without exposing body |
| Mantle/Vault | — | 4 | Ledges up to 1.5m |

- **Surface materials** modify noise: concrete ×1.0, glass/gravel ×1.8, carpet/mud ×0.5.
- **Stamina:** 100 units; sprint drains 15/s, regenerates 10/s after a 1s delay.

### 5.2 Health & Status
- **Health:** 100 HP, no regen. Healed by bandages (+25, 4s) and medkits (+60, 8s).
- **Bleeding:** Bullet/claw hits have 40% chance to apply bleed (-2 HP/s until bandaged).
- **Infection meter** (0–100): raised by infected melee hits (+15). At 100 → death. Reduced by Antivirals (-50). Meter persists between sorties (creates pressure to find antivirals).

### 5.3 Inventory
- **Grid-based** (8×6 base backpack). Items have sizes (pistol 2×1, rifle 4×1, hard drive 1×1).
- **Weight** affects noise: each 5kg over 15kg adds +1m noise radius.
- **Secure Pouch** (2×2): items here survive death. Intel goes here by default — *but* only if there's space. Choosing what to secure is a key decision.

## 6. Stealth System

### 6.1 Detection Model
Every NPC has an **Awareness** value 0–100 per known stimulus source.

```
Awareness gain per tick = (VisualStimulus + AudioStimulus) × Alertness multiplier
```

- **Visual stimulus** (humans only): raycast from NPC eyes to 5 player bones (head, chest, hands, feet). Modified by: distance, player light level (0–1 from `LightProbe`), player stance, whether player is moving.
- **Audio stimulus** (all NPCs): emitted `NoiseEvent(position, radius, type)`. NPCs inside radius receive intensity = 1 - (distance / radius).
- **Alertness multiplier:** Calm ×1.0, Suspicious ×1.5, Alert ×2.5.

### 6.2 NPC Awareness States
```
CALM ──(aw > 30)──▶ SUSPICIOUS ──(aw > 70)──▶ SEARCHING ──(aw = 100 / LOS)──▶ COMBAT
  ▲                     │                        │                              │
  └───(decay 60s)───────┴───(decay 40s)──────────┴───(lost 30s)─────────────────┘
```
- **Suspicious:** Turn toward stimulus, "Did you hear that?" bark. Investigate if aw > 50.
- **Searching:** Move to last known position, sweep 3 nearby search points.
- **Combat:** Engage. Humans call allies within 25m. Screamer infected summon a horde.

### 6.3 Player Feedback (diegetic-leaning HUD)
- **Detection meter:** small arc at screen center, fills white (suspicious) → orange (searching) → red (combat).
- **Noise indicator:** brief ripple ring on crosshair sized to the noise you just made.
- **Light gem:** small icon bottom-left showing player visibility (dark / dim / lit).
- No minimap. A paper map item can be opened (pauses nothing).

### 6.4 Stealth Tools
| Tool | Effect | Noise |
|---|---|---|
| Throwable bottle/brick | Distraction at impact point (radius 10m) | 10m |
| Suppressor | Gunshot noise 60m → 12m. Durability: 30 shots then degrades | — |
| Knife takedown | Instant kill on unaware humans / shamblers from behind. 2s animation. | 2m |
| Light switch / breaker | Turn off room lights. Humans investigate after 20s | 3m |
| Lockpick | Open locked doors. Minigame optional; base: 4s hold | 3m |
| Body carry | Move corpses out of sight. Bodies found → area goes Searching | 4m |

### 6.5 Heat System (world escalation)
A district-wide **Heat** value (0–100) rises with unsuppressed gunfire (+10), explosions (+25), Screamer calls (+20). Decays 1/min.
- **Heat > 40:** wandering infected spawn count doubles.
- **Heat > 70:** Raider patrol sent to investigate area. One extraction point closes.
- **Heat = 100:** Horde event (15–20 infected converge on player's last noise). Extract or die.

## 7. Combat

### 7.1 Weapons (vertical slice)
| Weapon | Type | Dmg | RPM | Base Noise | Attachment slots |
|---|---|---|---|---|---|
| Combat Knife | Melee | 35 / takedown | — | 2m | — |
| Crowbar | Melee | 50 | — | 5m | — |
| M9 Pistol | Sidearm | 28 | 300 | 60m | Muzzle, Optic |
| MP5 SMG | Primary | 24 | 800 | 65m | Muzzle, Optic, Grip |
| Hunting Rifle | Primary | 85 | 40 (bolt) | 90m | Muzzle, Optic |
| Pump Shotgun | Primary | 12×8 | 60 | 100m | Muzzle |

- **Ballistics:** hitscan with damage falloff for slice; projectile sim is a stretch goal.
- **Hit zones:** head ×2.5, torso ×1.0, limbs ×0.7.
- **Ammo:** 9mm (pistol/SMG), .308, 12ga. Scarce: an average sortie finds ~40 rounds total.

### 7.2 Attachments & Gear Mods (Light RPG layer)
- **Muzzle:** Suppressor (noise −80%, durability), Compensator (recoil −20%).
- **Optic:** Iron, Red Dot (ADS speed +15%), 4× Scope (rifle only).
- **Grip:** Vertical (recoil −15%), Laser (hipfire accuracy +25%, visible beam).
- **Armor:** None / Light (−15% dmg, +1m noise) / Heavy (−35% dmg, +3m noise, −10% speed).
- **Boots:** Standard / Padded (−1m noise on all surfaces) — crafted.
- Crafted at Safehouse **Workbench** from **Parts** (Scrap, Electronics, Fabric, Chemicals).

### 7.3 Skill Tree (3 branches × 5 nodes = 15 nodes)
Earn 1 Skill Point per banked **Intel** item.

| Ghost (stealth) | Scavenger (survival) | Operator (combat) |
|---|---|---|
| Soft Step: −1m noise crouched | Keen Eye: loot glints from 15m | Steady Hands: −15% recoil |
| Quick Takedown: 2s → 1.2s | Pack Mule: +2 backpack rows | Quick Reload: +25% |
| Shadow: −20% visibility in dim light | Field Medic: bandages +40 | Hardened: +20 max HP |
| Body Hider: carry at walk speed | Tinkerer: crafts cost −25% parts | Marksman: +15% headshot dmg |
| Phantom: takedowns silent (0m) | Secure Pouch 3×3 | Adrenaline: 3s slow-mo on detection (60s CD) |

## 8. Enemies

### 8.1 Infected
| Type | HP | Detection | Behavior |
|---|---|---|---|
| **Shambler** | 60 | Audio only (10m). Blind. | Idle wander. Slow (2 m/s). Swarms. Takedown-able. |
| **Listener** | 90 | Audio only (25m), very sensitive. | Stands still, head tracking. Sprints (6 m/s) to noise. Cannot be taken down from front. |
| **Screamer** | 120 | Audio (15m) + short vision (8m). | On detection: 3s scream (+20 Heat, summons all infected in 60m). Kill before scream = priority target. |
| **Brute** (stretch) | 400 | Audio 20m | Boss-tier. Avoid. |

### 8.2 Human Factions
| Faction | Where | Gear | Behavior |
|---|---|---|---|
| **Raiders** | Market Street checkpoint | Pistols, shotguns, no armor. | Patrol routes, campfire idle, loud conversations (audio cover for player). Fight infected on sight. Loot: ammo, scrap. |
| **Sentinel PMC** | Corporate Annex | SMGs, light armor, flashlights. | Tight patrols, radio check-ins (missed check-in → Searching). Flashlight cones increase player light level. Loot: suppressors, electronics. |

**Faction vs faction:** Raiders and Infected are hostile. PMC and Infected are hostile. Player can lure one into the other (throw a bottle near a horde toward a raider camp).

## 9. Intel & Narrative System

### 9.1 Intel Items
Physical pickups, each a `IntelResource` with: id, title, body text, category, zone, and `unlocks` list.

| Category | Examples | Count in slice |
|---|---|---|
| **Personal** | Diaries, phone notes, letters | 6 |
| **Faction** | Raider ledgers, PMC orders | 4 |
| **Medical** | Triage logs, symptom charts | 4 |
| **Corporate** | HALCYON-7 memos, emails, the final data drive | 4 |
| **Total** | | **18** |

### 9.2 Evidence Board (Safehouse)
- A wall in the Safehouse. Each banked intel item pins a card.
- Cards in the same **thread** (e.g., "Patient Zero", "The Cover-Up", "Sentinel Contract") connect with string when both are found.
- Completing a thread grants a **permanent unlock**: map annotation (marks a stash), a keycard location hint, or a new crafting recipe.
- Completing all 4 threads + retrieving the final data drive = vertical slice complete. Ending text: the handler's response, deliberately ambiguous.

### 9.3 Narrative Threads (slice)
1. **Patient Zero** — Who got sick first, and where. (Residential + Clinic intel) → Unlocks: Clinic back entrance.
2. **The Cordon** — Why the military never came back. (Raider radio logs + Personal) → Unlocks: extraction route map.
3. **Sentinel Contract** — Who is PMC guarding the Annex for, three years later? (Faction + Corporate) → Unlocks: Annex keycard location.
4. **HALCYON-7** — What the virus actually is. (Medical + Corporate) → Unlocks: finale (data drive location).

## 10. Death, Extraction, and Persistence

- **Extraction:** Reach any open extraction point, hold interact 5s. Return to Safehouse scene. All backpack items → Stash. Intel → Board. Skill points awarded.
- **Death:** Operator's body remains in the district with everything not in the Secure Pouch. A new Operator (same character — narrative hand-waves as "you survived, barely, and crawled back") spawns at Safehouse with starting kit. **One recovery attempt:** body persists for one sortie. If you die again, it's gone.
- **Persists forever:** Safehouse stash, board, skills, workbench upgrades, infection meter.
- **Persists per world:** Enemy deaths reset each sortie (re-populated). Opened doors/breakers reset. Looted containers stay looted for 3 sorties then partially refill.

## 11. UX & Controls (KB/M, gamepad stretch)

| Action | Key |
|---|---|
| Move / Sprint / Crouch / Prone | WASD / Shift / C / Z |
| Lean | Q / E |
| Interact / Hold interact | F |
| Fire / ADS | LMB / RMB |
| Reload / Melee / Throw | R / V / G |
| Inventory | Tab |
| Map | M |
| Weapon 1/2/3 (primary, sidearm, melee) | 1 / 2 / 3 |
| Flashlight (raises visibility!) | T |

## 12. Audio Direction
- Minimal music. A single low drone in the district; silence in the Safehouse except ambient hum.
- Diegetic audio is gameplay: every noise the player hears, NPCs hear too (same NoiseEvent bus).
- Infected have distinct idle vocalizations audible from 20m — the player's early warning.
- Human factions talk. Overheard dialog contains hints ("Boss says nobody goes near the clinic since Dan got dragged in").

## 13. Vertical Slice — Definition of Done

The slice is done when a first-time player can:
1. Start in the Safehouse, read the board (empty), pick a loadout, depart.
2. Navigate the greybox district, be detected by sound and sight, and survive by stealth.
3. Loot containers, find at least 3 intel items, and use a suppressor / knife takedown.
4. Die once, lose their loot, respawn, and recover their body.
5. Extract, bank intel, watch the board connect a thread, spend a skill point, craft padded boots.
6. Complete all 4 threads and the finale over ~5 sorties (60–90 minutes total).

## 14. Out of Scope (post-slice backlog)
Day/night cycle · projectile ballistics · gamepad · multiple districts · faction reputation · dialogue system · Brute enemy · save slots · localization · final art & audio · Steam integration.
