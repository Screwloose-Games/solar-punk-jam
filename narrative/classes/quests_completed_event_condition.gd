## This condition is satisfied when all of the configured quests have been completed
class_name QuestsCompletedEventCondition
extends EventCondition

@export var quests: Array[Quest]

func _init() -> void:
	init_quests()


func init_quests():
	await Engine.get_main_loop().process_frame # Required for @export values to populate
	for quest in quests:
		if not quest.quest_completed.is_connected(_on_quest_completed):
			quest.quest_completed.connect(_on_quest_completed)


func all_quests_completed():
	return quests.all(func(quest: Quest): return quest.is_complete)


func _on_quest_completed(_giver: String):
	if all_quests_completed():
		event_occured()
