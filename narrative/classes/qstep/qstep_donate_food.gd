class_name QuestStepDonateFood
extends QuestStep
## DONATE_FOOD quest step
## Used for when a certain amount of food must be donated

## Type of crop to be planted
@export var crop_type : Crop.CropType
## Amount of the crop to plant
@export var amount : int = 1


func set_active(val: bool):
	_signal = GlobalSignalBus.crop_planted
	_expected_args = [crop_type]
	goal = amount
	super.set_active(val)
