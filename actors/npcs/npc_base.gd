class_name NpcBase
extends CharacterBody3D

@export var character: DialogicCharacter
@onready var quest_marker_3d: QuestMarker3D = %QuestMarker3D
@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D
@onready var dialogue: DialogueComponent = %Dialogue
@onready var interact_notify: InteractNotifyComponent = %InteractNotify

#func _enter_tree():
	#pass
	#await get_tree().create_timer(1).timeout
	#check_child_readiness()

# Called when the node enters the scene tree for the first time.
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
	#quest_marker_3d.id = character.resource_name

#func check_child_readiness():
	#var all_decendents: Array[Node] = find_children("*")
	#for child in all_decendents:
		#if not child.is_node_ready():
			#print(child.name)
			#print(child.get_path())
			#pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
