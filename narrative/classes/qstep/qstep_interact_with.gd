class_name QuestStepInteractWith
extends QuestStep
## INTERACT_WITH quest step
## Used for when a specific interactable object must be interacted with

## The ID string of the specific interactable object
@export var interactable_id : String


func set_active(val: bool):
	_signal = GlobalSignalBus.object_interacted
	_expected_args = [interactable_id]
	super.set_active(val)
