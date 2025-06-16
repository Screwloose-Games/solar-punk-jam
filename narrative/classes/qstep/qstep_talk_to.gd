# TALK_TO quest step
# Used for when a specific NPC must be talked to
extends QuestStep
class_name QuestStepTalkTo

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
