class_name QuestStepHarvestCrop
extends QuestStep
## HARVEST_CROP quest step
## Used for when a certain type of crop must be harvested

## Type of crop to harvest
@export var crop : Crop
## Amount of crop to harvest
@export var amount : int = 1


func set_active(val: bool):
	_signal = GlobalSignalBus.crop_harvested
	_expected_args = [crop]
	goal = amount
	super.set_active(val)
