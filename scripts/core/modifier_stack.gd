class_name ModifierStack
extends RefCounted
## Aggregates modifier dictionaries from skills, attachments and gear.
## Keys ending in "_mult" multiply (default 1.0); keys ending in "_add" sum (default 0.0).
## Sources are tracked so they can be removed (e.g. un-equipping an attachment).

var _sources: Dictionary = {}  # StringName -> Dictionary


func add_source(source_id: StringName, modifiers: Dictionary) -> void:
	_sources[source_id] = modifiers.duplicate()


func remove_source(source_id: StringName) -> void:
	_sources.erase(source_id)


func clear() -> void:
	_sources.clear()


func get_mult(key: StringName) -> float:
	var result: float = 1.0
	for mods: Dictionary in _sources.values():
		if mods.has(key):
			result *= float(mods[key])
	return result


func get_add(key: StringName) -> float:
	var result: float = 0.0
	for mods: Dictionary in _sources.values():
		if mods.has(key):
			result += float(mods[key])
	return result


## Convenience: dispatches on suffix.
func get_value(key: StringName) -> float:
	var s: String = String(key)
	if s.ends_with("_mult"):
		return get_mult(key)
	if s.ends_with("_add"):
		return get_add(key)
	push_warning("ModifierStack: key '%s' has no _mult/_add suffix" % s)
	return 0.0


## Applies both kinds: (base + adds) * mults, using "<stat>_add" and "<stat>_mult".
func apply(stat: StringName, base: float) -> float:
	return (base + get_add(StringName(String(stat) + "_add"))) * get_mult(StringName(String(stat) + "_mult"))
