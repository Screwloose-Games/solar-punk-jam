extends Control

@onready var actions = {
	$ActionList/BtnFischer: "fischer_talk",
	$ActionList/BtnMarge: "marge_talk",
	$ActionList/BtnSunny: "sunny_talk",
	$ActionList/BtnWendy: "wendy_talk",
	$ActionList/BtnCamTest: "cam_test",
}


func _ready() -> void:
	Dialogic.signal_event.connect(_cam_change)
	for button in actions.keys():
		button.pressed.connect(_on_click.bind(actions[button]))


func _on_click(action : String):
	Dialogic.start(action)


func _cam_change(mode : String):
	match mode:
		"normal":
			$PCam1.priority = 10
			$PCam2.priority = 0
			$PCam3.priority = 0
		"dialogue":
			$PCam1.priority = 0
			$PCam2.priority = 10
			$PCam3.priority = 0
		"closeup":
			$PCam1.priority = 0
			$PCam2.priority = 0
			$PCam3.priority = 10
