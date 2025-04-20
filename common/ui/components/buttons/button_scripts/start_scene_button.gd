extends Button

func _ready() -> void:
    pressed.connect(_on_button_pressed)

func _on_button_pressed():
    pass
    # Load scene
    #get_tree().change_scene_to_file()
