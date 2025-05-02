extends Node

@export var structures: Dictionary[String, bool] = {
	"Battery": false,
	"Bench": false,
	"Bioreactor": false,
	"Birdhouse (on pole)": false,
	"Bush (flowers)": false,
	"Compost bin": false,
	"Hygiene station": false,
	"Insect Hotel": false,
	"Kitchen": false,
	"Kitchen sink": false,
	"Kitchen stove": false,
	"Lantern (on pole)": false,
	"Picnic Table": false,
	"Rain barrel": false,
	"Raised bed": false,
	"Vertical garden": false,
	"Recycling station": false,
	"Solar panel": false,
	"Tool library": false,
	"Tree": false,
	"Vegetables": false,
	"Waste bin": false,
	"Donation box": false,
	"Food stand": false,
}

func _ready() -> void:
	await owner.ready
	unlock_structures()

func unlock_structures():
	for structure in structures:
		if structures[structure]:
			StructureManager.register_structure(structure)
