extends Node
## The ONLY way to play 3D gameplay sound. Every play_3d call also emits a NoiseEvent
## so that what the player hears, NPCs hear. Pools AudioStreamPlayer3D nodes.

const POOL_SIZE: int = 24

var _pool: Array[AudioStreamPlayer3D] = []
var _next: int = 0


func _ready() -> void:
	for i: int in POOL_SIZE:
		var p: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
		p.bus = &"SFX"
		add_child(p)
		_pool.append(p)


## Plays a sound at position and emits the matching noise event.
## Pass noise_radius = 0.0 for sounds NPCs should not hear (rare: UI-ish diegetic feedback).
func play_3d(stream: AudioStream, position: Vector3, noise_radius: float, noise_type: StringName, source: Node, volume_db: float = 0.0) -> void:
	if stream != null:
		var p: AudioStreamPlayer3D = _pool[_next]
		_next = (_next + 1) % POOL_SIZE
		p.stream = stream
		p.global_position = position
		p.volume_db = volume_db
		p.play()
	if noise_radius > 0.0:
		EventBus.noise_emitted.emit(position, noise_radius, noise_type, source)


func play_ui(stream: AudioStream) -> void:
	if stream == null:
		return
	var p: AudioStreamPlayer = AudioStreamPlayer.new()
	p.bus = &"UI"
	p.stream = stream
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()
