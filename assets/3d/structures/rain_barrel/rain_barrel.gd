extends Node

@export var regen_rate_per_day: int = 5
@export var max_capacity: int = 20
@export var starting_water: int = 0

var current_water: int = 0

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D

func _ready() -> void:
	ResourcesManager.add_storage_capacity("Water", max_capacity)
	current_water = starting_water
	interactable_area_3d.interacted.connect(_on_interacted)
	EnvironmentManager.day_cycle_end.connect(_on_day_cycle_end)

func _on_day_cycle_end():
	await get_tree().create_timer(0.2).timeout # wait till the player goes to bed
	current_water = min(current_water + regen_rate_per_day, max_capacity)

func _on_interacted(_player: Player):
	if current_water > 0:
		ResourcesManager.gain_resource_enum(ResourcesManager.ResourceType.WATER, current_water)
		GlobalSignalBus.rain_barrel_collected.emit()
		current_water = 0
	else:
		# feedback that it's empty
		pass
	interactable_area_3d.stop_interacting()
