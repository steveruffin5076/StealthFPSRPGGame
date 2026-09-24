class_name State
extends Node
## One state in a StateMachine. Override the hooks you need.
## Access the owning entity via `machine.actor`.

var machine: StateMachine


func enter(_msg: Dictionary = {}) -> void:
	pass


func exit() -> void:
	pass


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass
