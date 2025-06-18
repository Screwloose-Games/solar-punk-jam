class_name QuestStepAcceptQuest
extends QuestStep
## ACCEPT_QUEST quest step
## Used for when the player must accept a certain quest

## ID string of the quest
@export var quest : Quest


func set_active(val: bool):
	_signal = QuestManager.quest_started
	_expected_args = [quest]
	super.set_active(val)
