class_name QuestStepTalkTo
extends QuestStep
## TALK_TO quest step
## Used for when a specific NPC must be talked to

## The NPC to be talked to
@export_enum(
	"kai",
	"trin",
	"mister",
	"kyle"
) var npc : String = "kai"


func set_active(val : bool):
	_signal = GlobalSignalBus.talked_to
	_expected_args = [npc]
	super.set_active(val)
