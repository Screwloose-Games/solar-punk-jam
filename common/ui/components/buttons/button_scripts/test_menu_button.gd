extends Button

func _ready() -> void:
	pressed.connect(func(): get_tree().change_scene_to_packed(SceneManager.SCENARIOS_MENU))
