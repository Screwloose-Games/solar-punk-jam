extends Node

@export var max_capacity: int = 10
@export var max_soil_output_per_day: int = 100
@export var max_waste_deposited_per_interaction: int = 2

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D

var current_waste: int = 0
var soil_ready: int = 0

func _ready() -> void:
	interactable_area_3d.interacted.connect(_on_interacted)
	EnvironmentManager.day_cycle_end.connect(_on_day_cycle_end)

func _on_day_cycle_end():
	await get_tree().create_timer(0.2).timeout # wait till the player goes to bed

	if current_waste > 0:
		var processed = min(current_waste, max_soil_output_per_day)
		soil_ready += processed
		current_waste -= processed

func _on_interacted(player: Player):
	if soil_ready > 0:
		EnvironmentManager.gain_resource("Soil", soil_ready)
		soil_ready = 0
	elif EnvironmentManager.has_at_least("Waste", 1) and current_waste < max_capacity:
		var space_left = max_capacity - current_waste
		var to_add = min(EnvironmentManager.get_resource_count("Waste"), max_waste_deposited_per_interaction)
		EnvironmentManager.spend_resource("Waste", to_add)
		current_waste += to_add
	else:
		# feedback that it's empty or can't accept more waste
		pass

	interactable_area_3d.stop_interacting()
