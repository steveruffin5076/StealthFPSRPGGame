extends Node
## Global signal bus. Contains signals ONLY — no logic, no state.
## Any system may emit; any system may listen. See docs/02_ARCHITECTURE.md §3, §5.

# --- Noise / stealth (the single detection channel) ---
## Emitted for every sound that NPCs could perceive. radius in metres.
## type is one of: &"footstep", &"gunshot", &"impact", &"melee", &"interact", &"voice", &"scream", &"explosion"
signal noise_emitted(position: Vector3, radius: float, type: StringName, source: Node)

# --- Player ---
signal player_spawned(player: Node3D)
signal player_died(position: Vector3)
signal player_visibility_changed(visibility: float)
signal player_health_changed(hp: float, max_hp: float)
signal player_infection_changed(value: float)

# --- World ---
signal heat_changed(value: float)
signal horde_event_started(position: Vector3)
signal extraction_started(point_id: StringName)
signal extraction_completed(point_id: StringName)
signal intel_collected(intel_id: StringName)
signal intel_banked(intel_id: StringName)
signal thread_completed(thread_id: StringName)

# --- NPC ---
signal npc_awareness_state_changed(npc: Node3D, from: StringName, to: StringName)
signal npc_died(npc: Node3D, killer: Node)

# --- Progression ---
signal skill_unlocked(skill_id: StringName)
signal item_crafted(item_id: StringName)

# --- UI ---
signal prompt_changed(text: String, hold_progress: float)
