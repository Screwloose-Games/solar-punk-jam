class_name CommunityBoardCanvasLayer
extends CanvasLayer

signal quest_accepted(quest: Quest)
signal closed

@export var quest: Quest:
	set(val):
		quest = val
		if not is_node_ready():
			await ready
		rerender()
		

@onready var quest_giver_label: Label = %QuestGiverLabel
@onready var name_label: Label = %NameLabel
@onready var description_label: Label = %DescriptionLabel
@onready var quest_objectives_v_box_container: VBoxContainer = %QuestObjectivesVBoxContainer
@onready var accept_button: Button = %AcceptButton
@onready var close_button: Button = %CloseButton


func _ready() -> void:
	accept_button.pressed.connect(_on_accept_pressed)
	visibility_changed.connect(_on_visibility_changed)
	close_button.pressed.connect(_on_close_pressed)

func _on_close_pressed():
	closed.emit()

func _on_visibility_changed():
	if visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_accept_pressed():
	QuestManager.start_quest_resource(quest)
	StructureManager.register_structure("Hygiene station")
	quest_accepted.emit(quest)

func rerender():
	quest_giver_label.text = quest.quest_giver
	name_label.text = quest.name
	description_label.text = quest.description
	
	for child in quest_objectives_v_box_container.get_children():
		child.queue_free()
	for objective in quest.objectives:
		var lbl = Label.new()
		lbl.text = objective.description
		quest_objectives_v_box_container.add_child(lbl)
		#quest_objectives_v_box_container.add_child
