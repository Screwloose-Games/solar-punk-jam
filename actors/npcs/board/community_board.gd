extends StaticBody3D

const TEX_BLANK_BOARD = "res://assets/3d/structures/community_board/t_message_board_baseColor.png"
const TEX_FULL_BOARD = "res://assets/3d/structures/community_board/t_message_board_flyers_baseColor.png"

@export var quest_list : Array[Quest]

var quest_index : int = 0
var posted_quest : Quest:
	get:
		if available_quests.is_empty():
			return null
		return available_quests[0]

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D
@onready var community_board_canvas_layer: CommunityBoardCanvasLayer = %CommunityBoardCanvasLayer
@onready var board_mat := $sm_message_board/sm_community_message_board.get_surface_override_material(0) as ShaderMaterial

var available_quests: Array[Quest]:
	get:
		return QuestManager.unlocked_quests.filter(func (q): return (q.state == Quest.QuestState.AVAILABLE))

func _ready() -> void:
	interactable_area_3d.interacted.connect(_on_interacted)
	community_board_canvas_layer.visible = false
	community_board_canvas_layer.quest_accepted.connect(_on_quest_accepted)
	community_board_canvas_layer.closed.connect(_on_board_closed)
	QuestManager.quests_changed.connect(update_queue)
	if not quest_list.is_empty():
		community_board_canvas_layer.quest = quest_list[quest_index]
	


func _process(_delta: float) -> void:
	if community_board_canvas_layer.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


# Get available quests by filtering Quest.state
# If there are no available quests, set board to be inactive
# If there are available quests, make the front of the
# available queue as the 'posted quest'
func update_queue():
	
	#var available_quests = quest_list.filter(func (q): return (q.state == Quest.QuestState.AVAILABLE))
	#var global_unlocked_quests: Array[Quest] = QuestManager.unlocked_quests.filter(func (q): return (q.state == Quest.QuestState.AVAILABLE))
	#available_quests.append_array(global_unlocked_quests)
	if available_quests.is_empty():
		interactable_area_3d.disabled = true
		board_mat.set_shader_parameter("texture_albedo", load(TEX_BLANK_BOARD))
	else:
		posted_quest = available_quests[0]
		interactable_area_3d.disabled = false
		board_mat.set_shader_parameter("texture_albedo", load(TEX_FULL_BOARD))


func _on_board_closed():
	community_board_canvas_layer.visible = false
	interactable_area_3d.stop_interacting()


func _on_quest_accepted():
	GlobalSignalBus.community_board_quest_accepted.emit()
	QuestManager.start_quest_resource(posted_quest)
	community_board_canvas_layer.visible = false
	var material := $sm_message_board/sm_community_message_board.get_surface_override_material(0) as ShaderMaterial
	if available_quests.is_empty():
		material.set_shader_parameter("texture_albedo", load(TEX_BLANK_BOARD))
		interactable_area_3d.disabled = true
	else:
		community_board_canvas_layer.quest = posted_quest
		material.set_shader_parameter("texture_albedo", load(TEX_FULL_BOARD))
	interactable_area_3d.stop_interacting()


func _on_interacted(_player: Player):
	community_board_canvas_layer.visible = !community_board_canvas_layer.visible
