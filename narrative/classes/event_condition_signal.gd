## EventCondition based on a signal. Base class intented to be extended with params.

class_name EventConditionSignal
extends EventCondition

## Name of the Global to listen to
var _autoload_name : String = "GlobalSignalBus"
## Name of the signal to listen for
var _signal_name : String = ""
## Array of expected parameters passed by the signal
var _expected_args : Array

var _autoload_instance : Node
var _signal : Signal


func _init() -> void:
	await Engine.get_main_loop().process_frame
	if not _signal:
		init_signal()
	subscribe()

func event_occured():
	if has_occured:
		return
	else:
		has_occured = true
		occured.emit()


func init_signal():
	init_autoload()
	if not _autoload_instance.has_signal(_signal_name):
		printerr("Autoload '", _autoload_name, "' does not have signal '", _signal_name, "'.")
		return
	_signal = _autoload_instance.get("_signal_name")


func init_autoload():
	var root_ref = Engine.get_main_loop().root
	var autoload_node_path = "/root/" + _autoload_name
	if not root_ref.has_node(autoload_node_path):
		printerr("Autoload node '", _autoload_name, "' not found in the scene tree.")
		return
	_autoload_instance = root_ref.get_node(autoload_node_path)
	if _autoload_instance == null:
		printerr("Failed to get autoload instance: ", _autoload_name)
		return


func subscribe():
	if not _signal.is_connected(_on_autoload_signal_emitted):
		var error_code = _signal.connect(_on_autoload_signal_emitted)
		if error_code == OK:
			print("Successfully subscribed to signal '", _signal.get_name(), "' on autoload '", _signal.get_object().get("name"), "'")
		else:
			printerr("Failed to connect to signal '", _signal.get_name(), "' on autoload '",
			_signal.get_object().get("name"), "'. Error code: ", error_code)


func unsubscribe():
	if _signal and _signal.is_connected(_on_autoload_signal_emitted):
		_signal.disconnect(_on_autoload_signal_emitted)


func _on_autoload_signal_emitted(a = null, b = null, c = null, d = null):
	var received_args = [a, b, c, d]
	for i in _expected_args.size():
		var expected_value = _expected_args[i]
		if expected_value != received_args[i]:
			return
	event_occured()
