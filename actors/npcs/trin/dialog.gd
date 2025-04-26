extends Node3D

@export var npc_id : String = ""

@onready var dialogue_indicator: Label3D = %DialogueIndicator
@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialogue_indicator.hide()
	interactable_area_3d.interacted.connect(_on_interacted)
	interactable_area_3d.selected.connect(_on_interactable_selected)
	interactable_area_3d.unselected.connect(_on_interactable_unselected)

func _on_interactable_selected():
	dialogue_indicator.show()

func _on_interactable_unselected():
	dialogue_indicator.hide()

func _on_interacted(player: Player):
	start_current_dialogue()

func start_current_dialogue():
	var dialogue = GameState.get_npc_dialogue(npc_id)
	if dialogue != "":
		Dialogic.start(dialogue)
		await Dialogic.timeline_ended
		interactable_area_3d.stop_interacting()
