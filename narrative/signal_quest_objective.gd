extends QuestObjective
class_name SignalQuestObjective

#@export var description : String = "Objective Description"
#@export var quest_value : String = ""
#@export var goal : int = 1
#@export var prerequisites : Array[int] = []
#@export var play_dialogue : String = ""

#var progress : int = 0
#var is_active : bool = false
#var is_unlocked : bool = false
#var is_completed : bool = false

## The global autoload on which to call the signal
@export_enum("GlobalSignalBus", "QuestManager", "EnvironmentManager") var autoload_name: String

## The name of the signal on the global autoload
@export var signal_name: String = ""

## Arguments expect passed to the signal
@export var expected_args: Array

var autoload_instance : Node


func set_active(val : bool):
	super.set_active(val)
	if is_active:
		subscribe()
	else:
		autoload_instance.disconnect(signal_name, _on_autoload_signal_emitted)


func _on_autoload_signal_emitted(a = null, b = null, c = null, d = null):
	var received_args = [a, b, c, d]
	for i in expected_args.size():
		var expected_value = expected_args[i]
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
		printerr("Failed to connect to signal '", signal_name, "' on autoload '", autoload_name, "'. Error code: ", error_code)
