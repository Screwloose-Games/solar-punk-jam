extends Node

const FILE_PATH = "res://narrative/quests/%s.tres"

var quests : Array[Quest] = []

signal quests_changed


func _ready() -> void:
	Dialogic.VAR.variable_changed.connect(_on_gamestate_changed)


func start_quest(file_name : String):
	var new_quest = load(FILE_PATH % file_name)
	quests.append(new_quest)
	new_quest.quest_state_changed.connect(_update_quests)
	new_quest.quest_completed.connect(_on_quest_complete)
	new_quest.start_quest()
	_update_quests()
	print("Quest started: %s" % new_quest.name)


func _on_gamestate_changed(_changes):
	for quest in quests:
		quest.check_progress()


func _on_quest_complete(giver : String):
	print("Quest completed.")
	Dialogic.VAR[giver + "_active"] = false
	Dialogic.VAR[giver + "_progress"] += 1
	print("Progress for NPC %s increased to %d" % [giver, Dialogic.VAR[giver + "_progress"]])
	_update_quests()


func _update_quests():
	quests_changed.emit()
