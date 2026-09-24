extends Node
## Persists GameState (and later the stash inventory) to user://save.json.
## Autosave triggers: extraction, death, entering Safehouse. No mid-sortie saves by design.

const SAVE_PATH: String = "user://save.json"


func save_game() -> bool:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveSystem: cannot open %s for write" % SAVE_PATH)
		return false
	file.store_string(JSON.stringify(GameState.to_dict(), "\t"))
	return true


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var text: String = FileAccess.get_file_as_string(SAVE_PATH)
	var parsed: Variant = JSON.parse_string(text)
	if not parsed is Dictionary:
		push_error("SaveSystem: save file corrupt")
		return false
	GameState.from_dict(parsed as Dictionary)
	return true


func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
