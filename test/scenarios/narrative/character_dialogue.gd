extends Node3D

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
	QuestManager.start_quest("qst_stones")
	Dialogic.signal_event.connect(_cam_change)
	for button in actions.keys():
		button.pressed.connect(_on_click.bind(actions[button]))


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if !event.pressed:
			match event.keycode:
				KEY_1:
					GlobalSignalBus.stick_collected.emit()
				KEY_2:
					GlobalSignalBus.limestone_collected.emit()
				KEY_3:
					GlobalSignalBus.sandstone_collected.emit()
				KEY_4:
					GlobalSignalBus.shale_collected.emit()


func _update_quests():
	var active_text = "ACTIVE:\n"
	var complete_text = "COMPLETE:\n"
	for quest in QuestManager.quests:
		if quest.is_complete:
			complete_text += "%s\n" % quest.name
		else:
			active_text += "%s\n" % quest.name
			for objective in quest.objectives:
				if objective.is_active:
					active_text += "- %s: %d / %d\n" % [objective.description, objective.progress, objective.count]
	$QuestInfo/Body.text = active_text + complete_text


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
