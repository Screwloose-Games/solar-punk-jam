extends Node3D

@export var npc_id = ""

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D


func _ready() -> void:
	GameState.game_state_changed.connect(_on_game_state_changed)
	interactable_area_3d.interacted.connect(_on_interacted)


func _on_game_state_changed():
	if (npc_id + "_met") in GameState.quest_values.keys():
		visible = !GameState.quest_values[npc_id + "_met"]
	elif (npc_id + "_active") in GameState.quest_values.keys():
		visible = !GameState.quest_values[npc_id + "_active"]


func _on_interacted(player: Player):
	visible = false
