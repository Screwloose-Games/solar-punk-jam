extends Node

@onready var camera_target_marker_3d: Marker3D = $CameraTargetMarker3D
@onready var phantom_camera_3d: PhantomCamera3D = $PhantomCamera3D
@onready var player: Player = %Player

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	player.cutscene_mode_enabled = true
	phantom_camera_3d.priority = 30
	Dialogic.start("a1d1_intro")
	await Dialogic.timeline_ended
	player.cutscene_mode_enabled = false
