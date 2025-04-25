extends Node

const FILE_PATH = "res://narrative/quests/%s.tres"
var quests : Array[Quest] = []

signal quests_changed


func start_quest(file_name : String):
	var new_quest = load(FILE_PATH % file_name)
	quests.append(new_quest)
	new_quest.quest_state_changed.connect(_update_quests)
	new_quest.quest_completed.connect(_update_quests)
	new_quest.start_quest()
	_update_quests()
	print("Quest started: %s" % new_quest.name)


func _update_quests():
	quests_changed.emit()
