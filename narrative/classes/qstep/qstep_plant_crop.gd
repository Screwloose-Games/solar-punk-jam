class_name QuestStepPlantCrop
extends QuestStep
## PLANT_CROP quest step
## Used for when a certain type of crop must be planted

## Type of crop to plant
@export var crop : Crop
## Amount of crop to plant
@export var amount : int = 1


func set_active(val: bool):
	_signal = GlobalSignalBus.crop_planted
	_expected_args = [crop]
	super.set_active(val)
