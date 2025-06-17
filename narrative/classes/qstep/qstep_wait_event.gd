class_name QuestStepWaitEvent
extends QuestStep
## WAIT_EVENT quest step
## Used when the player has to wait until a certain in game event

## ID string of the event
@export var event_id : String = "event_id"

var days_waited: int = 0


func set_active(val: bool):
	_signal = GlobalSignalBus.day_passed
	_expected_args = [event_id]
	super.set_active(val)
