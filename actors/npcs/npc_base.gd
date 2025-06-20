class_name NpcBase
extends CharacterBody3D

@export var character: DialogicCharacter
@onready var quest_marker_3d: QuestMarker3D = %QuestMarker3D
@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D
@onready var dialogue: DialogueComponent = %Dialogue
@onready var interact_notify: InteractNotifyComponent = %InteractNotify

func _ready() -> void:
	if character:
		var file_name: String = character.resource_path.get_file()
		var id: String = file_name.get_basename().to_lower()
		print(character.resource_name)
		print(character.resource_path)
		quest_marker_3d.id = id
		interactable_area_3d.interactable_id = id
		interact_notify.npc_id = id
		dialogue.npc_id = id
