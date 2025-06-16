class_name SignalQuestStepBase
extends QuestStep

var _expected_args: Array
var _signal: Signal


func set_active(val: bool):
	super.set_active(val)
	if is_active:
		subscribe()
	else:
		unsubscribe()


func subscribe():
	if not _signal:
		printerr("Signal is not set. Please set the signal before subscribing.")
		return
	if !_signal.is_connected(_on_autoload_signal_emitted):
		var error_code = _signal.connect(_on_autoload_signal_emitted)
		if error_code == OK:
			print(
				"Successfully subscribed to signal '",
				_signal.get_name(),
				"' on object '",
				_signal.get_object(),
				"'"
			)
		else:
			printerr(
				"Failed to connect to signal '",
				_signal.get_name(),
				"' on autoload '",
				_signal.get_object(),
				"'. Error code: ",
				error_code
			)


func unsubscribe():
	if _signal.is_connected(_on_autoload_signal_emitted):
		_signal.disconnect(_on_autoload_signal_emitted)


func _on_autoload_signal_emitted(a = null, b = null, c = null, d = null):
	var received_args = [a, b, c, d]
	for i in _expected_args.size():
		var expected_value = _expected_args[i]
		if expected_value != received_args[i]:
			return
	event_occured()


func event_occured():
	if is_completed:
		return
	progress += 1
	if progress >= goal:
		is_completed = true
		is_active = false
	else:
		progressed.emit()
