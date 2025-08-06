extends Node

const QST_A_1D_1_TRIN = preload("res://narrative/quests/qst_a1d1_trin.tres")

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
	QuestManager.unlock_quest_res(QST_A_1D_1_TRIN)
	player.cutscene_mode_enabled = false
