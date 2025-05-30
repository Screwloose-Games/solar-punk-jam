extends Node

@onready var environment: CapybaraEnvironment = %Environment
@onready var animation_player_2: AnimationPlayer = %AnimationPlayer2

@export var next_scene: PackedScene
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#await get_tree().process_frame
	#environment.is_raining = true
	#await get_tree().create_timer(2).timeout
	#animation_player_2.play("panright")
	##await get_tree().create_timer(4).timeout

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Continue"):
		SceneTransitionManager.change_scene_with_transition(next_scene, SceneManager.FADE_TRANSITION)
		
