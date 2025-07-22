extends StaticBody3D

const TEX_BLANK_BOARD = "res://assets/3d/structures/community_board/t_message_board_baseColor.png"
const TEX_FULL_BOARD = "res://assets/3d/structures/community_board/t_message_board_flyers_baseColor.png"

@export var quest_list : Array[Quest]

var quest_index : int = 0

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D
@onready var community_board_canvas_layer: CommunityBoardCanvasLayer = %CommunityBoardCanvasLayer


func _ready() -> void:
	interactable_area_3d.interacted.connect(_on_interacted)
	community_board_canvas_layer.visible = false
	community_board_canvas_layer.quest_accepted.connect(_on_quest_accepted)
	community_board_canvas_layer.closed.connect(_on_board_closed)
	if not quest_list.is_empty():
		community_board_canvas_layer.quest = quest_list[quest_index]


func _process(_delta: float) -> void:
	if community_board_canvas_layer.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_board_closed():
	community_board_canvas_layer.visible = false
	interactable_area_3d.stop_interacting()


func _on_quest_accepted():
	GlobalSignalBus.community_board_quest_accepted.emit()
	QuestManager.start_quest_resource(quest_list[quest_index])
	community_board_canvas_layer.visible = false
	quest_index += 1
	var material := $sm_message_board/sm_community_message_board.get_surface_override_material(0) as ShaderMaterial
	if quest_index >= quest_list.size():
		quest_index = quest_list.size() - 1
		material.set_shader_parameter("texture_albedo", load(TEX_BLANK_BOARD))
		interactable_area_3d.disabled = true
	else:
		community_board_canvas_layer.quest = quest_list[quest_index]
		material.set_shader_parameter("texture_albedo", load(TEX_FULL_BOARD))
	interactable_area_3d.stop_interacting()


func _on_interacted(_player: Player):
	community_board_canvas_layer.visible = !community_board_canvas_layer.visible
