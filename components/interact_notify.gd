extends Node3D

@export var npc_id = ""

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D


func _ready() -> void:
	visible = false
	QuestManager.quests_changed.connect(_on_quest_change)
	interactable_area_3d.interacted.connect(_on_interacted)


func _on_quest_change():
	visible = !Dialogic.VAR[npc_id + "_active"]


func _on_interacted(player: Player):
	GlobalSignalBus.talked_to.emit(npc_id)
	visible = false
