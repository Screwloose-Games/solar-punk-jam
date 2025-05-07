class_name CommunityBoardCanvasLayer
extends CanvasLayer

const HEADER_STRING = "Request: %s"
const BODY_STRING = "From: %s\nDetails:\n%s"

@onready var header : Label = %Header
@onready var body : Label = %Body
@onready var objectives : Label = %Objectives
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
	header.text = HEADER_STRING % quest.name
	body.text = BODY_STRING % [quest.quest_giver.capitalize(), quest.community_board_text]
	var obj_text = ""
	for objective in quest.objectives:
		obj_text += objective.description + "\n"
	objectives.text = obj_text
