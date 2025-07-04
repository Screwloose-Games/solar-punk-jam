extends Node

var globally_stored_waste: int = 0

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D

func _ready() -> void:
	interactable_area_3d.interacted.connect(_on_interacted)

func _on_interacted(_player: Player) -> void:
	if ResourcesManager.has_at_least(ResourcesManager.ResourceType.FOOD, 1):
		ResourcesManager.spend_resource(ResourcesManager.ResourceType.FOOD, 1)
		ResourcesManager.gain_resource_enum(ResourcesManager.ResourceType.WASTE, 1)
		GlobalSignalBus.food_donated.emit(1)
	else:
		# feedback to player: not enough food
		pass

	interactable_area_3d.stop_interacting()
