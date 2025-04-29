extends Node3D

@export var npc_id: String = ""

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D


func _ready() -> void:
	interactable_area_3d.interacted.connect(_on_interacted)


func _on_interacted(player: Player):
	start_current_dialogue()


func start_current_dialogue():
	var dialogue = GameState.get_npc_dialogue(npc_id)
	if dialogue != "":
		Dialogic.start(dialogue)
		await Dialogic.timeline_ended
		interactable_area_3d.stop_interacting()
