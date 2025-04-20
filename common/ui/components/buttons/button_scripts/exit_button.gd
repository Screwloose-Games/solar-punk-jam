extends Button

func _init():
  pressed.connect(_on_pressed)
  if OS.has_feature("web"):
    visible = false

func _on_pressed():
  get_tree().quit()
