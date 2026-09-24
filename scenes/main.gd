extends Node
## Root scene. Registers SceneRoot with SceneRouter and boots into the Safehouse.

@onready var _scene_root: Node = $SceneRoot


func _ready() -> void:
	SceneRouter.register_scene_root(_scene_root)
	SaveSystem.load_game()
	# Until P5-03 exists, this will log a missing-scene error and show an empty world. Expected.
	SceneRouter.go_to_safehouse()
