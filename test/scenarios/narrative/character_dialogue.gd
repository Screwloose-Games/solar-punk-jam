extends Control

@onready var actions = {
	$ActionList/BtnFischer: "fischer_talk",
	$ActionList/BtnMarge: "marge_talk",
	$ActionList/BtnSunny: "sunny_talk",
	$ActionList/BtnWendy: "wendy_talk",
}


func _ready() -> void:
	for button in actions.keys():
		button.pressed.connect(_on_click.bind(actions[button]))


func _on_click(action : String):
	Dialogic.start(action)
