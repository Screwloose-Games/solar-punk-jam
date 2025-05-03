extends Node3D

@export var npc_id = ""

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D


func _ready() -> void:
	QuestManager.npc_notified_new.connect(_on_new_notify)
	interactable_area_3d.interacted.connect(_on_interacted)


func _on_new_notify(id):
	if id == npc_id:
		visible = true


func _on_interacted(player: Player):
	visible = false
