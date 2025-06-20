class_name QuestStep
extends Resource
## Base quest step class
## Base logic for quest objectives

signal progressed
signal completed(this_step: QuestStep)

@export var description: String = "Objective Description"
@export var prerequisites: Array[int] = []
@export var play_dialogue: String = ""
# @export var dialogue_timeline: DialogicTimeline

@export_custom(PROPERTY_HINT_ENUM_SUGGESTION, "board,community_food_stand,go_to_bed_door,home_entrance,home_roof_garden,
kai,kelly,kyle,material_location,mister,trin,trin_compost,trin_garden,trin_water,vertical_garden,water")
var marker_id: String

var goal: int = 1
var progress : int = 0
var is_active : bool = false : set = set_active
var is_unlocked : bool = false
var is_completed : bool = false : set = set_complete
var markers: Array[QuestMarker3D] = []
var _signal: Signal
var _expected_args: Array
var _var_name : String = ""


func set_active(val : bool):
	is_active = val
	if is_active and marker_id:
		setup_markers()
	if is_active:
		subscribe()
		check_value()
	else:
		unsubscribe()


func event_occured():
	if is_completed:
		return
	progress += 1
	if progress >= goal:
		is_completed = true
		is_active = false
	else:
		progressed.emit()


func check_value():
	if is_active and _var_name != "":
		var value = QuestManager.get(_var_name)
		print("Objective check val: " + str(value))
		if int(value) >= goal:
			progress = goal
			is_completed = true
			is_active = false
		else:
			progress = int(value)
			progressed.emit()


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


func setup_markers():
	if marker_id:
		markers = QuestManager.get_quest_markers_by_id(marker_id)
		set_markers(true)


func set_markers(active: bool):
	if markers:
		for marker in markers:
			marker.active = active


func set_complete(val : bool):
	is_completed = val
	if is_completed:
		set_markers(false)
		completed.emit(self)
		GlobalSignalBus.quest_objective_completed.emit()
		set_active(false)


func reset():
	is_active = false
	is_unlocked = false
	is_completed = false


func _on_autoload_signal_emitted(a = null, b = null, c = null, d = null):
	var received_args = [a, b, c, d]
	for i in _expected_args.size():
		var expected_value = _expected_args[i]
		if expected_value != received_args[i]:
			return
	event_occured()
