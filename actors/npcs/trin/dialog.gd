class_name DialogueComponent
extends Node3D

static var dialogue_components: Array[DialogueComponent] = []

@export var npc_id: String = ""

var supress_default_dialogue: bool = false

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D

static func get_dialogue_component_by_id(id: String):
	for component in dialogue_components:
		if component.npc_id == id:
			return component
	return null

static func set_quest_talk_to_target(npc_id: String, is_target: bool):
	var component = get_dialogue_component_by_id(npc_id)
	if component:
		component.supress_default_dialogue = is_target
	else:
		print("DialogueComponent with npc_id '" + npc_id + "' not found.")

func _enter_tree() -> void:
	dialogue_components.append(self)

func _exit_tree() -> void:
	dialogue_components.erase(self)

func _ready() -> void:
	interactable_area_3d.interacted.connect(_on_interacted)

func _on_interacted(_player: Player):
	if !supress_default_dialogue:
		start_current_dialogue()
	interactable_area_3d.stop_interacting()

func has_dialogue():
	return DialogicResourceUtil.get_timeline_resource(npc_id + "_main") != null

func start_current_dialogue():
	if has_dialogue():
		Dialogic.start(npc_id + "_main")
		await Dialogic.timeline_ended
