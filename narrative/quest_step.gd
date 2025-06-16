extends Resource
class_name QuestStep

signal progressed
signal completed(this_objective: QuestStep)

enum QuestObjectiveType {
	CUSTOM,  # Legacy, complex and flexible
	INTERACT_WITH,  # the interactable must have an ID. A specific, custom string.
	INTERACT_WITH_TYPE,  # Any of a given TYPE. Any water barrel, any of a TYPE
	ACCEPT_QUEST,
	TALK_TO,
	BUILD_STRUCTURE,  # Strucutre has a structure id ENUM
	COLLECT_RESOURCE,  # By count. Collect a certain number.
	COLLECT_RESOURCE_TYPE,
	PLANT_CROP,
	GO_TO,  # your roof, a certain area. These have tags. They are Area3D
	WAIT_DAYS,  # wait a specific number of days to pass.
	WAIT_EVENT,  # Wait until a specific event occurs... List of events?
	HARVEST_CROP,  # any, specific type
	DONATE_FOOD,
	DELIVER_RESOURCE_TO,
	# -----------------
	ACHIEVE_RESOURCE_TARGET,  # Type of resource, target number
}

@export var description: String = "Objective Description"
@export var goal: int = 1
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

@export var type: QuestObjectiveType = QuestObjectiveType.CUSTOM

var progress : int = 0
var is_active : bool = false : set = set_active
var is_unlocked : bool = false
var is_completed : bool = false : set = set_complete
var markers: Array[QuestMarker3D] = []


func set_active(val : bool):
	is_active = val
	if is_active and marker_id:
		setup_markers()


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
