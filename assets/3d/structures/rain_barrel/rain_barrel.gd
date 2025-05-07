extends Node

@export var regen_rate_per_day: int = 5
@export var max_capacity: int = 20

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D

var current_water: int = 0

func _ready() -> void:
	interactable_area_3d.interacted.connect(_on_interacted)
	EnvironmentManager.day_cycle_end.connect(_on_day_cycle_end)

func _on_day_cycle_end():
	await get_tree().create_timer(0.2).timeout # wait till the player goes to bed
	current_water = min(current_water + regen_rate_per_day, max_capacity)

func _on_interacted(player: Player):
	if current_water > 0:
		EnvironmentManager.gain_resource("Water", current_water)
		current_water = 0
	else:
		# feedback that it's empty
		pass
	interactable_area_3d.stop_interacting()
