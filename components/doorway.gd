## Transports the player to the destination when interacted
class_name Doorway
extends Node3D

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D
@onready var destination: Marker3D = $Destination

func _ready() -> void:
	interactable_area_3d.interacted.connect(_on_interacted)

func _on_interacted(player: Player):
	move_to_destination(player)
	interactable_area_3d.stop_interacting()

func move_to_destination(player: Player):
	SceneTransitionManager.change_position_with_transition(player, destination, SceneManager.FADE_TRANSITION)
