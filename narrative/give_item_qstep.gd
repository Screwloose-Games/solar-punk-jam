class_name GiveItemQuestStep
extends SignalQuestStep

@export var recipient : String
@export var item : String


func set_active(val : bool):
	autoload_name = "GlobalSignalBus"
	signal_name = "item_given"
	expected_args = [recipient, item]
	super.set_active(val)
