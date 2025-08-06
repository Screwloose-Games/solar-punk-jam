extends Node

var qst_a1d1_trin = load("res://narrative/quests/qst_a1d1_trin.tres")

@onready var camera_target_marker_3d: Marker3D = $CameraTargetMarker3D
@onready var phantom_camera_3d: PhantomCamera3D = $PhantomCamera3D
@onready var player: Player = %Player

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	player.cutscene_mode_enabled = true
	phantom_camera_3d.priority = 30
	#await Dialogic.timeline_ended
	Dialogic.start("kai_DAY1S2_INTRODUCTION")
	await Dialogic.timeline_ended
	QuestManager.unlock_quest_res(qst_a1d1_trin)
	player.cutscene_mode_enabled = false
