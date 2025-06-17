class_name QuestStepCustom
extends QuestStep
## CUSTOM quest step, more generic and customizable
## Not intended for regular use, for objectives that other types don't cover

## Name of the Global to listen to
@export var autoload_name : String = "GlobalSignalBus"
## Name of the signal to listen for
@export var signal_name : String = ""
## Array of expected parameters passed by the signal
@export var expected_args : Array[String]
## Name of variable being tracked (optional)
@export var var_name : String = ""
## Target value for the tracked variable (optional)
@export var target_value : int = 1

var autoload_instance : Node


func set_active(val : bool):
	super.set_active(val)
	if is_active:
		subscribe()
		check_value()
	else:
		unsubscribe()


func event_occured():
	if is_completed:
		return
	progress += 1
	if progress >= target_value:
		is_completed = true
		is_active = false
	else:
		progressed.emit()


func check_value():
	if is_active:
		var value = QuestManager[var_name]
		print("Objective check val: " + str(value))
		if int(value) >= goal:
			progress = goal
			is_completed = true
			is_active = false
		else:
			progress = int(value)
			progressed.emit()


func subscribe():
	# Validation check 1: Does the autoload exist?
	var root_ref = Engine.get_main_loop().root
	var autoload_node_path = "/root/" + autoload_name
	if not root_ref.has_node(autoload_node_path):
		printerr("Autoload node '", autoload_name, "' not found in the scene tree.")
		return
	autoload_instance = root_ref.get_node(autoload_node_path)
	if autoload_instance == null:
		printerr("Failed to get autoload instance: ", autoload_name)
		return

	# Validation check 2: Does it have the correct signal?
	if not autoload_instance.has_signal(signal_name):
		printerr("Autoload '", autoload_name, "' does not have signal '", signal_name, "'.")
		return

	var error_code = autoload_instance.connect(signal_name, _on_autoload_signal_emitted)
	if error_code == OK:
		print("Successfully subscribed to signal '", signal_name, "' on autoload '", autoload_name, "'")
	else:
		printerr("Failed to connect to signal '", signal_name, "' on autoload '",
		autoload_name, "'. Error code: ", error_code)


func unsubscribe():
	if autoload_instance:
		autoload_instance.disconnect(signal_name, _on_autoload_signal_emitted)


func _on_autoload_signal_emitted(a = null, b = null, c = null, d = null):
	var received_args = [a, b, c, d]
	for i in expected_args.size():
		var expected_value = expected_args[i]
		if expected_value != received_args[i]:
			return
	event_occured()
