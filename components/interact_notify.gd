extends Node3D

@export var npc_id = ""

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D


func _ready() -> void:
	GameState.game_state_changed.connect(_on_game_state_changed)
	interactable_area_3d.interacted.connect(_on_interacted)


func _on_game_state_changed():
	print("Interact notify: GameState changed.")
	if npc_id in GameState.npcs.keys():
		print("Interact notify: Vis change on %s" % npc_id)
		var npc_data = GameState.npcs[npc_id]
		visible = (!npc_data.player_met or !npc_data.quest_active)


func _on_interacted(player: Player):
	visible = false
