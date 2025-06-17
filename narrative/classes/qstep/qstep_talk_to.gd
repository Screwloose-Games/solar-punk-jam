class_name QuestStepTalkTo
extends QuestStep
## TALK_TO quest step
## Used for when a specific NPC must be talked to

## The NPC to be talked to
@export_enum(
	"Kai:kai",
	"Trin:trin",
	"Mister:mister",
	"Kyle:kyle"
) var npc : String = "Kai"


func set_active(val : bool):
	_signal = GlobalSignalBus.talked_to
	_expected_args = [npc]
	super.set_active(val)
