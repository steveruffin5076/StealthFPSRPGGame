class_name RecipeResource
extends Resource
## Workbench recipe. inputs: { &"scrap": 3, &"fabric": 2 }.

@export var id: StringName
@export var output_item_id: StringName
@export var output_count: int = 1
@export var inputs: Dictionary = {}
@export var required_thread_id: StringName  # optional unlock gate
