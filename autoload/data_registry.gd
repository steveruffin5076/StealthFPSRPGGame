extends Node
## Loads every .tres under res://data/ at boot and indexes them by `id`.
## Usage: DataRegistry.items[&"m9_pistol"], DataRegistry.intel[&"diary_01"].

const DATA_ROOT: String = "res://data"

var items: Dictionary = {}     # StringName -> ItemResource
var intel: Dictionary = {}     # StringName -> IntelResource
var skills: Dictionary = {}    # StringName -> SkillResource
var recipes: Dictionary = {}   # StringName -> RecipeResource
var npcs: Dictionary = {}      # StringName -> NPCArchetypeResource


func _ready() -> void:
	_scan(DATA_ROOT)


func _scan(dir_path: String) -> void:
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		return
	dir.list_dir_begin()
	var name: String = dir.get_next()
	while name != "":
		var full: String = dir_path.path_join(name)
		if dir.current_is_dir():
			if not name.begins_with("."):
				_scan(full)
		elif name.ends_with(".tres"):
			_register(load(full))
		name = dir.get_next()
	dir.list_dir_end()


func _register(res: Resource) -> void:
	if res == null or not ("id" in res):
		return
	var id: StringName = res.get("id")
	if id == &"":
		push_warning("DataRegistry: %s has empty id" % res.resource_path)
		return
	if res is IntelResource:
		intel[id] = res
	elif res is SkillResource:
		skills[id] = res
	elif res is RecipeResource:
		recipes[id] = res
	elif res is NPCArchetypeResource:
		npcs[id] = res
	elif res is ItemResource:
		items[id] = res
