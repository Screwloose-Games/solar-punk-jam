class_name QuestStepInteractType
extends QuestStep
## INTERACT_WITH_TYPE quest step
## Used for when a specific *type* of interactable object must be interacted with

## The type of interactable to be interacted with
@export_enum("Compost bin",
	"Picnic Table",
	"Raised bed",
	"Rain barrel",
	"Vertical garden",
	"Recycling station",
	"Solar panel",
	"Waste bin",
	"Donation box",
	"Food stand",
) var interactable_type : String


func set_active(val: bool):
	_signal = GlobalSignalBus.structure_interacted
	_expected_args = [interactable_type]
	super.set_active(val)
