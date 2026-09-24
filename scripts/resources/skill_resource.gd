class_name SkillResource
extends Resource
## One node in the 3x5 skill tree. Costs 1 skill point.

enum Branch { GHOST, SCAVENGER, OPERATOR }

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var branch: Branch = Branch.GHOST
@export_range(1, 5) var tier: int = 1
@export var prerequisite_id: StringName
@export var modifiers: Dictionary = {}
