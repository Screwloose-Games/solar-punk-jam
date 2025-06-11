extends Node3D

signal talked_to
signal quests_available_changed(has_quests: bool)

@export var npc_id = ""
@export var show_indicator: bool = true

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D

var has_quests_available: bool = false:
	set(val):
		if val != has_quests_available:
			quests_available_changed.emit(val)
		has_quests_available = val

func _ready() -> void:
	visible = false
	QuestManager.quests_changed.connect(_on_quest_change)
	interactable_area_3d.interacted.connect(_on_interacted)


func _on_quest_change():
	hide()
	for quest in QuestManager.unlocked_quests:
		if quest.quest_giver == npc_id:
			has_quests_available = true
			if show_indicator:
				show()
			return
	has_quests_available = false


func _on_interacted(player: Player):
	GlobalSignalBus.talked_to.emit(npc_id)
	talked_to.emit()
	visible = false
