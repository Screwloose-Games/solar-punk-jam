class_name BuildStructQuestStep
extends SignalQuestStep

@export var structure_type : String


func set_active(val : bool):
	autoload_name = "StructureManager"
	signal_name = "built_structure"
	expected_args = [structure_type]
	super.set_active(val)
