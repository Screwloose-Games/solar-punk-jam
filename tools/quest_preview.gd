class_name QuestPreview
extends PanelContainer

signal quest_dragged(quest: Quest)
signal dropped

@export var quest: Quest
@onready var label: Label = Label.new()

func _ready() -> void:
	label.text = quest.name
	label.set_meta("quest", quest)
	add_child(label)

func _get_drag_data(_pos):
	var preview = label.duplicate()
	var drag_data = {
		"quest": quest,
		"from": self
	}
	set_drag_preview(preview)
	return drag_data

func _can_drop_data(_pos, data) -> bool:
	return false

func _drop_data(_pos, data) -> void:
	pass
