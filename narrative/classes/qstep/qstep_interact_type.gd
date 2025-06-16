# INTERACT_WITH_TYPE quest step
# Used for when a specific *type* of interactable object must be interacted with
extends QuestStep
class_name QuestStepInteractType

@export var interactable_type : String


func set_active(val: bool):
	_signal = GlobalSignalBus.structure_interacted
	_expected_args = [interactable_type]
	super.set_active(val)
