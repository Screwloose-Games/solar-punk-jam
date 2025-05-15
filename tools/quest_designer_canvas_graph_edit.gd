@tool
class_name QuestDesignerCanvas
extends GraphEdit


@export var layout: QuestDesignerLayout


@onready var save_layout_button: Button = %SaveLayoutButton
@onready var restore_layout_button: Button = %RestoreLayoutButton
@onready var organize_layout_button: Button = %OrganizeLayoutButton


func _ready():
	organize_layout_button.pressed.connect(_on_organize_pressed)
	save_layout_button.pressed.connect(_save_layout_pressed)
	restore_layout_button.pressed.connect(_on_restore_layout_pressed)
	child_entered_tree
	child_exiting_tree
	if layout:
		layout.restore_layout()
	else:
		layout = QuestDesignerLayout.new()

func _on_organize_pressed():
	#for child in get_children():
		#set_selected(child)
	arrange_nodes()

func _save_layout_pressed():
	var quest_edit_children = get_children().filter(func(child): return child is QuestEditUi)
	var quest_edit_nodes: Array[QuestEditUi] = []
	quest_edit_nodes.append_array(quest_edit_children)
	layout.save_layout(quest_edit_nodes, zoom, scroll_offset)

func _on_restore_layout_pressed():
	for child in get_children():
		if child is QuestEditUi:
			child.queue_free()
	
	var new_children = layout.restore_layout()
	zoom = layout.zoom
	scroll_offset = layout.scroll_offset
	for child in new_children:
		add_child(child)
	

var quests_on_cavas: Array[Quest]:
	get:
		var children = get_children()
		var quest_uis = children.filter(func(child): return child is QuestEditUi)
		var quests = quest_uis.map(func(quest_ui): return quest_ui.quest)
		var qsts: Array[Quest] = []
		qsts.append_array(quests)
		return qsts

func _can_drop_data(position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.has("quest") and data["quest"] is Quest

func _drop_data(position: Vector2, data: Variant) -> void:
	if not _can_drop_data(position, data):
		return

	var quest: Quest = data["quest"]
	var quest_ui: QuestEditUi = QuestEditUi.new()
	quest_ui.quest = quest
	add_child(quest_ui)
	quest_ui.set_position_offset(position)
	quest_ui.set_position_offset((get_local_mouse_position() + scroll_offset) / zoom)
	data.get("from").dropped.emit()
	
