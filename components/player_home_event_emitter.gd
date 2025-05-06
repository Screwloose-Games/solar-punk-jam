extends Node

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D
@onready var ground_doorway: Doorway = %GroundDoorway

func _ready() -> void:
	ground_doorway.interactable_area_3d.interacted.connect(_on_entry_interacted)

func _on_entry_interacted(player: Player):
	GlobalSignalBus.player_entered_home.emit()
