extends Node3D


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if !event.pressed:
			match event.keycode:
				KEY_1:
					Dialogic.VAR.materials_collected += 1
					QuestManager.check_quests({})
				KEY_2:
					Dialogic.VAR.hygiene_built = true
					QuestManager.check_quests({})
				KEY_3:
					Dialogic.VAR.build_flag1 = true
					QuestManager.check_quests({})
				KEY_4:
					Dialogic.VAR.build_flag2 = true
					QuestManager.check_quests({})
