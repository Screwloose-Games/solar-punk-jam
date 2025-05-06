class_name Crop
extends Resource

enum CropState {
	PLANTED,
	HARVESTABLE
}

static var planting_requirements: Dictionary[String, int] = {
	"Soil": 1,
	"Seeds": 1,
	"Water": 1,
}

enum CropType {
	RADISH,
	STRAWBERRY,
}

@export var name: String = "Radish" 
@export var type: CropType = CropType.RADISH
@export var planted_scene: PackedScene
@export var mature_scene: PackedScene
#@export var icon
@export var state: CropState = CropState.PLANTED
@export var harvest_amount: int = 2
@export var days_to_mature: int = 0

var days_planted: int = 0

static func has_enough():
	return EnvironmentManager.has_enough(Crop.planting_requirements)

func is_harvestable():
	return state == CropState.HARVESTABLE

func mature_crop():
	days_planted += 1
	if days_planted >= days_to_mature:
		state = CropState.HARVESTABLE
