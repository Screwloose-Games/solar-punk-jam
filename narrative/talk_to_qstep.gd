class_name TalkToQuestStep
extends SignalQuestStep

@export var npc_id: String = "npc_id"


func set_active(val: bool):
	_signal = GlobalSignalBus.talked_to
	expected_args = [npc_id]
	super.set_active(val)
