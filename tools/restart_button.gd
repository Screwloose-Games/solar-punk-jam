extends Button

func _ready() -> void:
	pressed.connect(get_tree().reload_current_scene)
