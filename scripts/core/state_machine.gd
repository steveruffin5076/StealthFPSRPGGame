class_name StateMachine
extends Node
## Generic node-based finite state machine. Children must be State nodes.
## Used by player movement and NPC brains alike.

signal state_changed(from: StringName, to: StringName)

@export var initial_state: State
@export var actor: Node

var current: State = null
var _states: Dictionary = {}


func _ready() -> void:
	for child: Node in get_children():
		if child is State:
			var s: State = child as State
			s.machine = self
			_states[StringName(child.name)] = s
	if initial_state != null:
		current = initial_state
		current.enter()


func _process(delta: float) -> void:
	if current != null:
		current.update(delta)


func _physics_process(delta: float) -> void:
	if current != null:
		current.physics_update(delta)


func transition_to(target: StringName, msg: Dictionary = {}) -> void:
	if not _states.has(target):
		push_error("StateMachine: unknown state '%s' on %s" % [target, get_path()])
		return
	var from: StringName = &""
	if current != null:
		from = StringName(current.name)
		if from == target:
			return
		current.exit()
	current = _states[target]
	current.enter(msg)
	state_changed.emit(from, target)


func is_in(name: StringName) -> bool:
	return current != null and StringName(current.name) == name
