class_name QuestStep
extends Resource

signal progressed
signal completed(quest_step: QuestStep)

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
var progress: int = 0
var is_active: bool = false:
	set = set_active
var is_unlocked: bool = false
var is_completed: bool = false:
	set = set_complete
var markers: Array[QuestMarker3D] = []


func set_active(val: bool):
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


func set_complete(val: bool):
	is_completed = val
	if is_completed:
		set_markers(false)
		completed.emit(self)
		GlobalSignalBus.quest_objective_completed.emit()


func reset():
	is_active = false
	is_unlocked = false
	is_completed = false
