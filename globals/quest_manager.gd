extends Node

const FILE_PATH = "res://narrative/quests/%s.tres"

var quest_values = {
	
}
var quests : Array[Quest] = []

signal quests_changed


func _ready() -> void:
	GameState.game_state_changed.connect(_on_gamestate_changed)


func start_quest(file_name : String):
	var new_quest = load(FILE_PATH % file_name)
	quests.append(new_quest)
	new_quest.quest_state_changed.connect(_update_quests)
	new_quest.quest_completed.connect(_on_quest_complete)
	new_quest.start_quest()
	_update_quests()
	print("Quest started: %s" % new_quest.name)


func _on_gamestate_changed():
	for quest in quests:
		quest.check_progress()


func _on_quest_complete(giver : String):
	print("Quest completed.")
	GameState.complete_quest(giver)
	_update_quests()


func _update_quests():
	quests_changed.emit()
