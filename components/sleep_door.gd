extends Node3D

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D

func _ready() -> void:
	interactable_area_3d.interacted.connect(_on_interacted)

func _on_interacted(player: Player):
	EnvironmentManager.end_day()
	SceneTransitionManager.change_position_with_transition(player, player, SceneManager.FADE_TRANSITION)
	await get_tree().create_timer(0.4).timeout
	interactable_area_3d.stop_interacting()
