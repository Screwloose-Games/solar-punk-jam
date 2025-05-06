## Allows a node to hand out quests. Works with QuestManager
class_name QuestGiver
extends Node

@export var id: String
@export var available_quests_queue: Array[Quest] = []

var next_quest: Quest:
	get:
		return available_quests_queue.front()

func get_next_quest() -> Quest:
	return available_quests_queue.pop_front()

func add_quest(quest: Quest) -> void:
	available_quests_queue.append(quest)

func has_quest_available() -> bool:
	return not available_quests_queue.is_empty()

func _enter_tree() -> void:
	register()

func _exit_tree() -> void:
	unregister()

func register() -> void:
	QuestManager.register_quest_giver(self)

func unregister() -> void:
	QuestManager.unregister_quest_giver(self)
