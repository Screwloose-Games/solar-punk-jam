extends Control

@onready var actions = {
	$ActionList/BtnFischer: "fischer_talk",
	$ActionList/BtnMarge: "marge_talk",
	$ActionList/BtnSunny: "sunny_talk",
	$ActionList/BtnWendy: "wendy_talk",
	$ActionList/BtnCamTest: "cam_test",
}


func _ready() -> void:
	QuestManager.quests_changed.connect(_update_quests)
	QuestManager.start_quest("qst_sticks")
	Dialogic.signal_event.connect(_cam_change)
	for button in actions.keys():
		button.pressed.connect(_on_click.bind(actions[button]))


func _update_quests():
	var body_text = ""
	for quest in QuestManager.active_quests:
		body_text += "Quest: %s\n" % quest.name
		for objective in quest.objectives:
			if objective.is_active:
				body_text += "- %s: %d / %d\n" % [objective.description, objective.progress, objective.count]
	$QuestInfo/Body.text = body_text


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


func _on_click(action : String):
	Dialogic.start(action)


func _on_button_pressed() -> void:
	GlobalSignalBus.stick_collected.emit()
