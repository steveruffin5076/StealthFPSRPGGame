extends Node
## Swaps the active gameplay scene (Safehouse <-> District) under main.tscn's SceneRoot.
## Handles fade and sortie bookkeeping. Nothing else.

const SAFEHOUSE_SCENE: String = "res://scenes/world/safehouse/safehouse.tscn"
const DISTRICT_SCENE: String = "res://scenes/world/district/district.tscn"

var _scene_root: Node = null
var _current: Node = null


func register_scene_root(root: Node) -> void:
	_scene_root = root


func go_to_safehouse(extracted: bool = false) -> void:
	if extracted:
		SaveSystem.save_game()
	await _swap(SAFEHOUSE_SCENE)


func go_to_district() -> void:
	GameState.sortie_count += 1
	await _swap(DISTRICT_SCENE)


func _swap(path: String) -> void:
	assert(_scene_root != null, "SceneRouter: register_scene_root() not called")
	if _current != null:
		_current.queue_free()
		await _current.tree_exited
	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		push_error("SceneRouter: missing scene %s" % path)
		return
	_current = packed.instantiate()
	_scene_root.add_child(_current)
