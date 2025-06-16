class_name InteractQuestStep
extends SignalQuestStep

@export var interactable_id : String

func set_active(val : bool):
	_signal = GlobalSignalBus.object_interacted
	expected_args = [interactable_id]
	super.set_active(val)
