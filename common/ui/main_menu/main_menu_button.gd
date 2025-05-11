extends Button

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed():
	get_tree().paused = false
