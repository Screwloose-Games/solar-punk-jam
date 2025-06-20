class_name QuestStepTalkTo
extends QuestStep
## TALK_TO quest step
## Used for when a specific NPC must be talked to

## The NPC to be talked to
@export_custom(PROPERTY_HINT_ENUM_SUGGESTION,"kelly,kai,kyle,mister,trin")
var npc : String = "kai"

func set_active(val : bool):
	_signal = GlobalSignalBus.talked_to
	_expected_args = [npc]
	DialogueComponent.set_quest_talk_to_target(npc, val)
	super.set_active(val)
