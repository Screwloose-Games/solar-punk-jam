class_name QuestLine
extends Resource
## A queue of quests. When one is completed, the next one immediately becomes active.

signal completed
signal quest_completed(quest: Quest)
signal quest_started(quest: Quest)

@export var name: String
## The name of the quest line. Breif, unique, human readable

@export var quests: Array[Quest]
## The quests in sequential order

var active_quest: Quest
## The current, active quest

func start():
	start_next_quest()

func start_next_quest():
	var next_quest: Quest = quests.pop_front()
	if next_quest is Quest:
		next_quest.start_quest()
	else:
		complete()

func complete():
	pass
