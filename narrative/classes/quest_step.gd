class_name QuestStep
extends Resource
## Base quest step class
## Base logic for quest objectives

signal progressed
signal completed(this_step: QuestStep)

enum QuestStepType {
	CUSTOM,  				# [x] Legacy, complex and flexible
	INTERACT_WITH,  		# [x] The interactable must have an ID. A specific, custom string.
	INTERACT_WITH_TYPE,  	# [x] Any of a given TYPE. Any water barrel, any of a TYPE
	ACCEPT_QUEST,			# [x] Accept a certain quest
	TALK_TO,				# [x] Talk to a certain NPC
	BUILD_STRUCTURE,  		# [x] Build a certain structure
	COLLECT_RESOURCE,  		# [] By count. Collect a certain number.
	COLLECT_RESOURCE_TYPE,	# [] Collect a certain amount of a certain resource.
	PLANT_CROP,				# [x] Plant a certain amount of any crop or a specific type.
	GO_TO,  				# [x] your roof, a certain area. These have tags. They are Area3D
	WAIT_DAYS,  			# [] Wait a specific number of days to pass.
	WAIT_EVENT,  			# [] Wait until a specific event occurs. List of events?
	HARVEST_CROP,  			# [x] Harvest a certain amount of any crop or a specific type.
	DONATE_FOOD,			# [x] Donate a certain amount of food
	GIVE_RESOURCE_TO,		# [] Give a certain amount of a certain resource to a certain NPC
	HAVE_RESOURCE,			# [x] Type of resource, target number
	GET_ITEM, 				# [] Receive a certain item
	GIVE_ITEM,				# [] Give a certain item to a certain NPC
}

@export var description: String = "Objective Description"
@export var prerequisites: Array[int] = []
@export var play_dialogue: String = ""
# @export var dialogue_timeline: DialogicTimeline

@export_enum(
	"trin",
	"mom",
	"home_entrance",
	"mister",
	"material_location",
	"board",
	"water",
	"trin_garden",
	"home_roof_garden",
	"go_to_bed_door",
	"trin_compost",
	"trin_water",
	"community_food_stand",
	"vertical_garden"
)
var marker_id: String

@export var type: QuestStepType = QuestStepType.CUSTOM

var goal: int = 1
var progress : int = 0
var is_active : bool = false : set = set_active
var is_unlocked : bool = false
var is_completed : bool = false : set = set_complete
var markers: Array[QuestMarker3D] = []

var _signal: Signal
var _expected_args: Array
var _var_name : String = "var_name"


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
	if is_active:
		var value = QuestManager[_var_name]
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
