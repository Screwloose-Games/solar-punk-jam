class_name SignalQuestStep
extends SignalQuestStepBase

# The global autoload on which to call the signal
@export_enum("GlobalSignalBus", "QuestManager", "EnvironmentManager") var autoload_name: String

# The name of the signal on the global autoload
@export var signal_name: String = ""

# Arguments expect passed to the signal
@export var expected_args: Array

var _autoload_instance: Node


func _setup():
	_autoload_instance = get_autoload_instance(autoload_name)
	if signal_name:
		_signal = _autoload_instance.get(signal_name)


func _init():
	if !Engine.get_main_loop().root.is_node_ready():
		await Engine.get_main_loop().root.ready
	_setup()


func set_active(val: bool):
	super.set_active(val)


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


func get_autoload_instance(global_name: StringName):
	var root_ref = Engine.get_main_loop().root
	var autoload_node_path = "/root/" + global_name
	if not root_ref.has_node(autoload_node_path):
		printerr("Autoload node '", global_name, "' not found in the scene tree.")
		return
	return root_ref.get_node(autoload_node_path)


func get_signal(name: StringName) -> Signal:
	if _autoload_instance == null:
		printerr("Autoload instance is null. Cannot get signal.")
	if not _autoload_instance.has_signal(name):
		printerr("Autoload '", autoload_name, "' does not have signal '", name, "'.")
	return _autoload_instance.get(name)
