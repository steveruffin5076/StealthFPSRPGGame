class_name ConsumableResource
extends ItemResource
## Bandage, medkit, antiviral. Effects applied over use_time seconds.

@export var heal_amount: float = 0.0
@export var stops_bleeding: bool = false
@export var infection_delta: float = 0.0
@export var use_time: float = 4.0
