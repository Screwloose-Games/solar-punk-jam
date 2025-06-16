## Build a structure
class_name BuildStructQuestStep
extends SignalQuestStepBase

@export var structure_name: String


func set_active(val: bool):
	_signal = StructureManager.built_structure
	_expected_args = [structure_name]
	super.set_active(val)
