class_name CommunityBoardCanvasLayer
extends CanvasLayer

@onready var quest_giver_label: Label = %QuestGiverLabel
@onready var name_label: Label = %NameLabel
@onready var description_label: Label = %DescriptionLabel
@onready var quest_objectives_v_box_container: VBoxContainer = %QuestObjectivesVBoxContainer
@onready var accept_button: Button = %AcceptButton
@onready var close_button: Button = %CloseButton

var quest: Quest:
	set(val):
		quest = val
		if not is_node_ready():
			await ready
		rerender()

signal quest_accepted
signal closed


func _ready() -> void:
	accept_button.pressed.connect(emit_signal.bind("quest_accepted"))
	visibility_changed.connect(_on_visibility_changed)
	close_button.pressed.connect(emit_signal.bind("closed"))


func _on_visibility_changed():
	if visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


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
