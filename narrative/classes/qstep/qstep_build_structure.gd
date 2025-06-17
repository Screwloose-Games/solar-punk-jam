class_name QuestStepBuildStructure
extends QuestStep
## BUILD_STRUCTURE quest step
## Used for when a certain structure must be built

enum StructureType {
	BATTERY,
	BENCH,
	BIOREACTOR,
	BIRDHOUSE,
	FLOWER_BUSH,
	COMPOST_BIN,
	HYGIENE_STATION,
	INSECT_HOTEL,
	KITCHEN,
	LANTERN,
	PICNIC_TABLE,
	RAIN_BARREL,
	RAISED_BED,
	VERTICAL_GARDEN,
	RECYCLING_STATION,
	SOLAR_PANEL,
	TOOL_LIBRARY,
	TREE,
	VEGETABLES,
	WASTE_BIN,
	DONATION_BOX,
	FOOD_STAND,
}

## Type of structure to be built
@export var structure_type : StructureType


func set_active(val: bool):
	_signal = StructureManager.built_structure
	_expected_args = [structure_type]
	super.set_active(val)
