class_name GetItemQuestStep
extends SignalQuestStep

@export var item : String


func set_active(val : bool):
	autoload_name = "GlobalSignalBus"
	signal_name = "item_received"
	expected_args = [item]
	super.set_active(val)
