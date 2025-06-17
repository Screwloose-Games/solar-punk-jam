class_name QuestStepWaitDays
extends QuestStep
## WAIT_DAYS quest step
## Used when the player has to wait X number of days in game

## Number of days to wait
@export var days_to_wait : int = 1

var days_waited: int = 0


func set_active(val: bool):
	_signal = GlobalSignalBus.day_passed
	_expected_args = []
	goal = days_to_wait
	super.set_active(val)
