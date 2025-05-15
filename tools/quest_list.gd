class_name QuestListEditor
extends VBoxContainer

@onready var quest_designer_canvas: QuestDesignerCanvas = %QuestDesignerCanvas

var quest_resources: Array[Quest] = []

var previews: Dictionary[Quest, QuestPreview] ={}

func _ready() -> void:
	scan_for_quests("res://narrative/")
	print("Found quests: ", quest_resources)
	list_quests(quest_resources)
	quest_designer_canvas.child_entered_tree.connect(_on_quest_enterd_tree)
	quest_designer_canvas.child_exiting_tree.connect(_on_quest_exit_tree)

func _on_quest_exit_tree(node: Node):
	if node is QuestEditUi:
		if previews.has(node.quest):
			previews[node.quest].show()
	handle_visibility()

func _on_quest_enterd_tree(node: Node):
	if node is QuestEditUi:
		if previews.has(node.quest):
			previews[node.quest].hide()
	handle_visibility()

func scan_for_quests(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			if file_name != "." and file_name != "..":
				scan_for_quests(path.path_join(file_name))
		elif file_name.ends_with(".tres") or file_name.ends_with(".res"):
			var file_path = path.path_join(file_name)
			if ResourceLoader.exists(file_path):
				var resource = ResourceLoader.load(file_path)
				if resource is Quest:
					quest_resources.append(resource)
		file_name = dir.get_next()
	dir.list_dir_end()

func _on_preview_dropped(preview: QuestPreview):
	preview.hide()
	handle_visibility()
	

func handle_visibility():
	if is_inside_tree():
		await get_tree().process_frame
	for quest in quest_resources:
		if quest in quest_designer_canvas.quests_on_cavas:
			previews[quest].hide()
		else:
			previews[quest].show()

func list_quests(quests: Array[Quest]) -> void:
	for quest in quests:
		var preview := QuestPreview.new()
		preview.quest = quest
		preview.dropped.connect(_on_preview_dropped.bind(preview))
		add_child(preview)
		previews[quest] = preview
		if quest in quest_designer_canvas.quests_on_cavas:
			preview.hide()
		
