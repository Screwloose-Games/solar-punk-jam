extends Button

func _ready() -> void:
	pass
	pressed.connect(func(): get_tree().change_scene_to_packed(SceneManager.MAIN_LEVEL))
