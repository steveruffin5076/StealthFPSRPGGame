class_name Interactable
extends Node3D
## Base for anything the player can use with F. Put on collision layer 4 (interactable).
## Override the four methods. hold_time > 0 turns it into a hold interaction.


func get_prompt() -> String:
	return "Interact"


func get_hold_time() -> float:
	return 0.0


func can_interact(_player: Node3D) -> bool:
	return true


func interact(_player: Node3D) -> void:
	pass
