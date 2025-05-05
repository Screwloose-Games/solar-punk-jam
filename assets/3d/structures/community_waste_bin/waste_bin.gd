extends Node

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D

var globally_stored_waste: int = 0

func _ready() -> void:
	interactable_area_3d.interacted.connect(_on_interacted)

func _on_interacted(player: Player) -> void:
	if EnvironmentManager.has_at_least("Food", 1):
		EnvironmentManager.dona
		EnvironmentManager.spend_resource("Food", 1)
		GlobalSignalBus.food_donated.emit(1)
		#EnvironmentManager.gain_resource("Community", community_per_donation)
	else:
		# feedback to player: not enough food
		pass

	interactable_area_3d.stop_interacting()
