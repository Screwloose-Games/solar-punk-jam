extends Node

const FILE_PATH = "res://narrative/quests/%s.tres"
var active_quests : Array[Quest] = []
var completed_quests : Array[int] = []

signal quests_changed


func start_quest(file_name : String):
	var load_quest = load(FILE_PATH % file_name)
	active_quests.append(load_quest)
	load_quest.quest_state_changed.connect(_update_quests)
	load_quest.quest_completed.connect(_update_quests)
	load_quest.start_quest()
	_update_quests()
	print("Quest started: %s" % load_quest.name)


func _update_quests():
	quests_changed.emit()
