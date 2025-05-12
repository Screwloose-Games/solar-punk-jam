extends Node

@export var community_per_donation: int = 1

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D

func _ready() -> void:
	interactable_area_3d.interacted.connect(_on_interacted)

func _on_interacted(_player: Player) -> void:
	if ResourcesManager.has_at_least("Food", 1):
		ResourcesManager.deposit_resource("Food", 1)
		ResourcesManager.spend_resource("Food", 1)
		GlobalSignalBus.food_donated.emit(1)
		ResourcesManager.gain_resource("Community", community_per_donation)
	else:
		# feedback to player: not enough food
		pass

	interactable_area_3d.stop_interacting()
