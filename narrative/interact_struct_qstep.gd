class_name InteractStructureQuestStep
extends SignalQuestStep

@export var structure_type : String


func set_active(val : bool):
	autoload_name = "GlobalSignalBus"
	signal_name = "structure_interacted"
	expected_args = [structure_type]
	super.set_active(val)
