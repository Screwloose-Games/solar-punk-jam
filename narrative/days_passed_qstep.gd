## Wait for a day to pass in the game.
class_name DaysPassedQuestStep
extends SignalQuestStepBase

var days_waited: int = 0


func set_active(val: bool):
	_signal = GlobalSignalBus.day_passed
	_expected_args = []
	super.set_active(val)
