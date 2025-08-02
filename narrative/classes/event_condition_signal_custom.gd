## This condition is satisfied when the signal has been emitted with the provided arguments.
class_name EventConditionSignalCustom
extends EventConditionSignal

## Name of the Global to listen to
@export var autoload_name : String = "GlobalSignalBus":
	set(val):
		_autoload_name = autoload_name
## Name of the signal to listen for
@export var signal_name : String = "":
	set(val):
		_signal_name = signal_name
## Array of expected parameters passed by the signal
@export var expected_args : Array[String]:
	set(val):
		_expected_args = expected_args
