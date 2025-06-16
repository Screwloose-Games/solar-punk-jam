# WAIT_EVENT quest step
# Used when the player has to wait until a certain in game event
extends QuestStep
class_name QuestStepWaitEvent

var days_waited: int = 0


func set_active(val: bool):
	_signal = GlobalSignalBus.day_passed
	_expected_args = []
	super.set_active(val)
