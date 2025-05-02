extends Node

const FILE_PATH = "res://narrative/quests/%s.tres"

var quests : Array[Quest] = []

signal quests_changed


func _ready() -> void:
	Dialogic.VAR.variable_changed.connect(check_quests)
	EnvironmentManager.UpdatedAvailableResources.connect(update_resources)
	StructureManager.StructureBuilt.connect(update_structures)


func start_quest(file_name : String):
	var new_quest = load(FILE_PATH % file_name)
	quests.append(new_quest)
	new_quest.quest_state_changed.connect(emit_signal.bind("quests_changed"))
	new_quest.quest_completed.connect(_on_quest_complete)
	new_quest.start_quest()
	quests_changed.emit()
	print("Quest started: %s" % new_quest.name)


func update_structures():
	check_quests({})


func update_resources():
	check_quests({})


func check_quests(_changes):
	for quest in quests:
		quest.check_progress()


func _on_quest_complete(giver : String):
	print("Quest completed.")
	Dialogic.VAR[giver + "_active"] = false
	Dialogic.VAR[giver + "_progress"] += 1
	print("Progress for NPC %s increased to %d" % [giver, Dialogic.VAR[giver + "_progress"]])
	quests_changed.emit()
