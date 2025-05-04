extends StaticBody3D

@export var quest_list : Array[Quest]

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D
@onready var community_board_canvas_layer: CommunityBoardCanvasLayer = %CommunityBoardCanvasLayer

var quest_index : int = 0


func _ready() -> void:
	QuestManager.quests_changed.connect(_on_quests_changed)
	interactable_area_3d.interacted.connect(_on_interacted)
	community_board_canvas_layer.visible = false
	community_board_canvas_layer.quest_accepted.connect(_on_quest_accepted)
	community_board_canvas_layer.closed.connect(_on_board_closed)
	community_board_canvas_layer.quest = quest_list[quest_index]


func _on_board_closed():
	community_board_canvas_layer.visible = false
	interactable_area_3d.stop_interacting()


func _on_quest_accepted():
	community_board_canvas_layer.visible = false
	QuestManager.start_quest_resource(quest_list[quest_index])
	Dialogic.VAR.board_active = true
	interactable_area_3d.stop_interacting()


func _on_interacted(player: Player):
	if !Dialogic.VAR.board_active:
		community_board_canvas_layer.visible = !community_board_canvas_layer.visible
	else:
		interactable_area_3d.stop_interacting()


func show_community_board_ui():
	pass


func _on_quests_changed():
	if !Dialogic.VAR.board_active:
		quest_index += 1
		if quest_index >= quest_list.size():
			quest_index = quest_list.size() - 1
			Dialogic.VAR.board_active = true
		else:
			community_board_canvas_layer.quest = quest_list[quest_index]
