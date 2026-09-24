extends Node
## Runtime session state: operator, heat, infection, sortie count, world flags.
## Serialised by SaveSystem. Contains no scene references.

const HEAT_MAX: float = 100.0
const HEAT_DECAY_PER_MIN: float = 1.0
const UNSUPPRESSED_GUNSHOT_RADIUS: float = 30.0

var heat: float = 0.0:
	set(value):
		heat = clampf(value, 0.0, HEAT_MAX)
		EventBus.heat_changed.emit(heat)

var infection: float = 0.0:
	set(value):
		infection = clampf(value, 0.0, 100.0)
		EventBus.player_infection_changed.emit(infection)

var sortie_count: int = 0
var skill_points: int = 0
var unlocked_skills: Array[StringName] = []
var collected_intel: Array[StringName] = []
var completed_threads: Array[StringName] = []
## Keyed by stable node path inside the district scene.
var world_flags: Dictionary = {}
## Null when no corpse to recover. {position: Array[float], items: Array, sortie: int}
var corpse: Dictionary = {}


func _ready() -> void:
	EventBus.noise_emitted.connect(_on_noise_emitted)


func _process(delta: float) -> void:
	if heat > 0.0:
		heat -= HEAT_DECAY_PER_MIN / 60.0 * delta


func _on_noise_emitted(_position: Vector3, radius: float, type: StringName, _source: Node) -> void:
	match type:
		&"gunshot":
			if radius > UNSUPPRESSED_GUNSHOT_RADIUS:
				heat += 10.0
		&"scream":
			heat += 20.0
		&"explosion":
			heat += 25.0


func to_dict() -> Dictionary:
	return {
		"version": 1,
		"operator": {
			"skills": unlocked_skills.duplicate(),
			"skill_points": skill_points,
			"infection": infection,
		},
		"board": {
			"collected_intel": collected_intel.duplicate(),
			"completed_threads": completed_threads.duplicate(),
		},
		"world_flags": world_flags.duplicate(true),
		"corpse": corpse.duplicate(true),
		"sortie_count": sortie_count,
		"heat": heat,
	}


func from_dict(data: Dictionary) -> void:
	var op: Dictionary = data.get("operator", {})
	unlocked_skills.assign(op.get("skills", []))
	skill_points = int(op.get("skill_points", 0))
	infection = float(op.get("infection", 0.0))
	var board: Dictionary = data.get("board", {})
	collected_intel.assign(board.get("collected_intel", []))
	completed_threads.assign(board.get("completed_threads", []))
	world_flags = data.get("world_flags", {})
	corpse = data.get("corpse", {})
	sortie_count = int(data.get("sortie_count", 0))
	heat = float(data.get("heat", 0.0))
