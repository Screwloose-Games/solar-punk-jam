extends StaticBody3D

@export var quest_list : Array[Quest]
@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D
@onready var community_board_canvas_layer: CommunityBoardCanvasLayer = %CommunityBoardCanvasLayer

var quest_index : int = 0


func _ready() -> void:
	$InteractNotify.quests_available_changed.connect(quests_available_changed)
	QuestManager.quest_completed.connect(_on_quest_complete)
	interactable_area_3d.interacted.connect(_on_interacted)
	community_board_canvas_layer.visible = false
	community_board_canvas_layer.quest_accepted.connect(_on_quest_accepted)
	community_board_canvas_layer.closed.connect(_on_board_closed)
	if not quest_list.is_empty():
		community_board_canvas_layer.quest = quest_list[quest_index]


func quests_available_changed(val):
	var material := $sm_message_board/sm_community_message_board.get_surface_override_material(0) as ShaderMaterial
	if val:
		material.set_shader_parameter("texture_albedo", load("res://assets/3d/structures/community_board/t_message_board_flyers_baseColor.png"))
	else:
		material.set_shader_parameter("texture_albedo", load("res://assets/3d/structures/community_board/t_message_board_baseColor.png"))

func _on_board_closed():
	community_board_canvas_layer.visible = false
	interactable_area_3d.stop_interacting()


func _on_quest_accepted():
	GlobalSignalBus.community_board_quest_accepted.emit()
	community_board_canvas_layer.visible = false
	QuestManager.start_quest_resource(quest_list[quest_index])
	Dialogic.VAR.board_active = true
	interactable_area_3d.stop_interacting()


func _on_interacted(player: Player):
	GlobalSignalBus.community_board_interacted.emit()
	GlobalSignalBus.object_interacted.emit("board")
	if !Dialogic.VAR.board_active:
		community_board_canvas_layer.visible = !community_board_canvas_layer.visible
	else:
		interactable_area_3d.stop_interacting()


func show_community_board_ui():
	pass

func _process(delta: float) -> void:
	if community_board_canvas_layer.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_quest_complete(_giver : String):
	if !Dialogic.VAR.board_active:
		quest_index += 1
		if quest_index >= quest_list.size():
			quest_index = quest_list.size() - 1
			$InteractNotify.hide()
			Dialogic.VAR.board_active = true
		else:
			community_board_canvas_layer.quest = quest_list[quest_index]
