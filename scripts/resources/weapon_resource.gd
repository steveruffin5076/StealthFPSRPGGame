class_name WeaponResource
extends ItemResource
## Firearm / melee data. See GDD §7.1.

enum WeaponClass { MELEE, SIDEARM, PRIMARY }

@export var weapon_class: WeaponClass = WeaponClass.SIDEARM
@export var damage: float = 28.0
@export var rounds_per_minute: float = 300.0
@export var noise_radius: float = 60.0
@export var ammo_type: StringName = &"9mm"
@export var magazine_size: int = 15
@export var pellets: int = 1
@export var falloff_start_m: float = 20.0
@export var falloff_end_m: float = 60.0
@export var falloff_min_mult: float = 0.5
@export var recoil_vertical: float = 1.0
@export var recoil_horizontal: float = 0.3
@export var attachment_slots: Array[StringName] = []
@export var viewmodel_scene: PackedScene
