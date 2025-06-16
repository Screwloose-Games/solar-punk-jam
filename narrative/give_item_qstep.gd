class_name GiveItemQuestStep
extends SignalQuestStepBase

@export var recipient: String
@export var item: String

func set_active(val: bool):
	_signal = GlobalSignalBus.item_given
	_expected_args = [recipient, item]
	super.set_active(val)
