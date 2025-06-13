extends Node

@export var max_capacity: int = 10
@export var max_soil_output_per_day: int = 100
@export var max_waste_deposited_per_interaction: int = 2
@export var starting_soil: int = 0

var current_waste: int = 0
var soil_ready: int = 0

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D

func _ready() -> void:
	soil_ready = starting_soil
	interactable_area_3d.interacted.connect(_on_interacted)
	EnvironmentManager.day_cycle_end.connect(_on_day_cycle_end)

func _on_day_cycle_end():
	await get_tree().create_timer(0.2).timeout # wait till the player goes to bed

	if current_waste > 0:
		var processed = min(current_waste, max_soil_output_per_day)
		soil_ready += processed
		current_waste -= processed

func _on_interacted(_player: Player):
	if soil_ready > 0:
		ResourcesManager.gain_resource_enum(ResourcesManager.ResourceType.SOIL, soil_ready)
		GlobalSignalBus.compost_collected.emit()
		soil_ready = 0
	elif ResourcesManager.has_at_least(ResourcesManager.ResourceType.WASTE, 1) and current_waste < max_capacity:
		var space_left = max_capacity - current_waste
		var to_add = min(
			ResourcesManager.get_resource_count(ResourcesManager.ResourceType.WASTE),
			max_waste_deposited_per_interaction
		)
		ResourcesManager.spend_resource(ResourcesManager.ResourceType.WASTE, to_add)
		current_waste += to_add
		GlobalSignalBus.waste_deposited.emit()
	else:
		# feedback that it's empty or can't accept more waste
		pass

	interactable_area_3d.stop_interacting()
