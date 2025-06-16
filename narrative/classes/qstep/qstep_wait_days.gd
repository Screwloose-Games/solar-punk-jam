# WAIT_DAYS quest step
# Used when the player has to wait X number of days in game
extends QuestStep
class_name QuestStepWaitDays

var days_waited: int = 0


func set_active(val: bool):
	_signal = GlobalSignalBus.day_passed
	_expected_args = []
	super.set_active(val)
