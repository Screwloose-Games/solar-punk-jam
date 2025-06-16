class_name GetItemQuestStep
extends SignalQuestStepBase

@export var item: String

func set_active(val: bool):
	_signal = GlobalSignalBus.item_received
	_expected_args = [item]
	super.set_active(val)
	
