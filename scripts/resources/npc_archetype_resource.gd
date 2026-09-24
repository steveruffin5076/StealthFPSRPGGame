class_name NPCArchetypeResource
extends Resource
## Data for one enemy type (Shambler, Raider, ...). See GDD §8.

@export var id: StringName
@export var display_name: String
@export var faction: StringName = &"infected"
@export var max_hp: float = 60.0
@export var walk_speed: float = 2.0
@export var run_speed: float = 4.0
@export var can_see: bool = false
@export var vision_range: float = 0.0
@export var vision_fov_deg: float = 110.0
@export var hearing_range: float = 10.0
@export var hearing_sensitivity: float = 1.0
@export var melee_damage: float = 15.0
@export var melee_infection: float = 0.0
@export var takedown_from_front: bool = false
@export var weapon_id: StringName
@export var loot_table: Resource
