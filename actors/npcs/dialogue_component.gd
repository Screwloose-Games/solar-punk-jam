class_name DialogueComponent
extends Node3D

# TODO: Consider just querying QuestManager for info,
# this seems like a whole parallel system for one function
static var dialogue_components: Array[DialogueComponent] = []

# TODO: Just get the parent's id/name, as this is a component anyway
@export var npc_id: String = ""
@export var main_timeline: DialogicTimeline

var supress_default_dialogue: bool = false

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D


static func get_dialogue_component_by_id(id: String):
	for component in dialogue_components:
		var this_parent = component.get_parent()
		if is_instance_valid(this_parent):
			if this_parent is NpcBase:
				if this_parent.id == id:
					return component
	return null


static func set_quest_talk_to_target(id: String, is_target: bool):
	var component = get_dialogue_component_by_id(id)
	if component:
		component.supress_default_dialogue = is_target
	else:
		print("DialogueComponent with npc_id '" + id + "' not found.")


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


func start_current_dialogue():
	# Order of precedence for choosing dialogue to play
	# 1. If currently linked to QuestStepTalkTo, play relevant dialogue
	# 2. If NPC has a quest available, play relevant dialogue
	# 3. Default dialogue
	if main_timeline != null:
		Dialogic.start(main_timeline)
		await Dialogic.timeline_ended
