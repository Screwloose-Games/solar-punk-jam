extends StaticBody3D


@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D
@onready var community_board_canvas_layer: CommunityBoardCanvasLayer = %CommunityBoardCanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable_area_3d.interacted.connect(_on_interacted)
	community_board_canvas_layer.visible = false
	community_board_canvas_layer.quest_accepted.connect(_on_quest_accepted)
	community_board_canvas_layer.closed.connect(_on_baord_closed)

func _on_baord_closed():
	community_board_canvas_layer.visible = false
	interactable_area_3d.stop_interacting()

func _on_quest_accepted(_quest: Quest):
	community_board_canvas_layer.visible = false
	interactable_area_3d.stop_interacting()

func _on_interacted(player: Player):
	community_board_canvas_layer.visible = ! community_board_canvas_layer.visible

func show_community_board_ui():
	pass

func get_next_quest():
	pass
	
	#Dialogic.start(npc_id + "_main")
	#await Dialogic.timeline_ended
	#interactable_area_3d.stop_interacting()
