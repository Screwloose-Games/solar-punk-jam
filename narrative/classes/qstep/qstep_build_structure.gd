class_name QuestStepBuildStructure
extends QuestStep
## BUILD_STRUCTURE quest step
## Used for when a certain structure must be built

enum StructureType {
}

## Type of structure to be built
@export_enum(
	"Battery",
	"Bench",
	"Bioreactor",
	"Birdhouse (on pole)",
	"Bush (flowers)",
	"Compost bin",
	"Hygiene station",
	"Insect Hotel",
	"Kitchen",
	"Lantern (on pole)",
	"Picnic Table",
	"Rain barrel",
	"Raised bed",
	"Vertical garden",
	"Recycling station",
	"Solar panel",
	"Tool library",
	"Tree",
	"Vegetables",
	"Community Waste Bin",
	"Donation box",
	"Food stand",
) var structure_type : String


func set_active(val: bool):
	_signal = StructureManager.built_structure
	_expected_args = [structure_type]
	super.set_active(val)
