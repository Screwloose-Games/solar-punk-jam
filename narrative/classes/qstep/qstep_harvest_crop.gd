# HARVEST_CROP quest step
# Used for when a certain type of crop must be harvested
extends QuestStep
class_name QuestStepHarvestCrop

@export var crop_type : Crop.CropType
@export var amount : int = 1

func set_active(val: bool):
	_signal = GlobalSignalBus.crop_harvested
	_expected_args = [crop_type]
	goal = amount
	super.set_active(val)
