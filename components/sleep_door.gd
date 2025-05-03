extends Node3D

@export var time_to_sleep: float
@export var player: Player
@export var wake_up_location: Node3D

var is_sleeping: bool = false

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D

func _ready() -> void:
	interactable_area_3d.interacted.connect(_on_interacted)
	EnvironmentManager.day_cycle_update.connect(_on_day_cycle_update)

func _on_day_cycle_update(time: float):
	if is_sleeping:
		return
	if time >= time_to_sleep:
		is_sleeping = true
		
		SceneTransitionManager.change_position_with_transition(player, wake_up_location, SceneManager.FORCE_SLEEP_TRANSITION)
		await SceneTransitionManager.faded_out
		is_sleeping = false

func _on_interacted(player: Player):
	is_sleeping = true
	EnvironmentManager.end_day()
	SceneTransitionManager.change_position_with_transition(player, player, SceneManager.FADE_TRANSITION)
	await SceneTransitionManager.faded_in
	is_sleeping = false
	interactable_area_3d.stop_interacting()
