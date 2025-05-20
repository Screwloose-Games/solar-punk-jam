class_name QuestDesignerLayout
extends Resource

@export var zoom: float
@export var scroll_offset: Vector2
@export var layout: Dictionary[Quest, Vector2]

func save_layout(quest_edit_nodes: Array[QuestEditUi], new_zoom = 1, new_scroll_offset=Vector2.ZERO):
	zoom = new_zoom
	scroll_offset = new_scroll_offset
	var new_layout: Dictionary[Quest, Vector2] = {}
	for quest_edit in quest_edit_nodes:
		new_layout[quest_edit.quest] = quest_edit.position_offset
	layout.clear()
	layout.merge(new_layout)
	ResourceSaver.save(self)

func restore_layout() -> Array[QuestEditUi]:
	var quest_edit_nodes: Array[QuestEditUi] = []
	for quest in layout.keys():
		var quest_edit_node = QuestEditUi.new()
		quest_edit_node.quest = quest
		quest_edit_node.position_offset = layout[quest]
		quest_edit_nodes.append(quest_edit_node)
	return quest_edit_nodes
