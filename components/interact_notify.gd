extends Node3D

@export var npc_id = ""

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D


func _ready() -> void:
	Dialogic.VAR.variable_changed.connect(_on_game_state_changed)
	interactable_area_3d.interacted.connect(_on_interacted)


func _on_game_state_changed(_changes):
	visible = !Dialogic.VAR[npc_id + "_met"] or \
		!Dialogic.VAR[npc_id + "_active"]


func _on_interacted(player: Player):
	visible = false
