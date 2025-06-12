class_name TalkToQuestStep
extends SignalQuestStep

@export var npc_id : String = "npc_id"


func set_active(val : bool):
	autoload_name = "GlobalSignalBus"
	signal_name = "npc_interacted"
	expected_args = [npc_id]
	super.set_active(val)
