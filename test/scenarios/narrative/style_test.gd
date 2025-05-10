extends Control

func _ready() -> void:
	$Button.pressed.connect(_on_pressed)


func _on_pressed():
	Dialogic.start("intro_fullscreen")
