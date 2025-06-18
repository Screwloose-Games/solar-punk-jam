class_name QuestStepDonateFood
extends QuestStep
## DONATE_FOOD quest step
## Used for when a certain amount of food must be donated

## Amount of food to donate
@export var amount : int = 1


func set_active(val: bool):
	_signal = GlobalSignalBus.food_donated
	_expected_args = []
	goal = amount
	super.set_active(val)
