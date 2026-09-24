class_name ItemResource
extends Resource
## Base data for every inventory item. Instances live in res://data/items/**.tres.

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var icon: Texture2D
@export var grid_size: Vector2i = Vector2i(1, 1)
@export var weight_kg: float = 0.5
@export var max_stack: int = 1
@export var world_scene: PackedScene
