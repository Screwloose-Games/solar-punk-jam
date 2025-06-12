class_name InteractQuestStep
extends SignalQuestStep

@export var interactable_id : String


func set_active(val : bool):
	autoload_name = "GlobalSignalBus"
	signal_name = "object_interacted"
	expected_args = [interactable_id]
	super.set_active(val)
