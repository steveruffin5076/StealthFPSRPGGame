class_name AttachmentResource
extends ItemResource
## Weapon attachment. `modifiers` keys use _mult/_add suffixes (see ModifierStack).
## Example suppressor: { &"noise_mult": 0.2 }, max_durability 30.

@export var slot: StringName = &"muzzle"
@export var modifiers: Dictionary = {}
@export var max_durability: int = 0  # 0 = does not degrade
