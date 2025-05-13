@tool
class_name QuestEditUi
extends GraphNode

@export var quest: Quest:
	set(value):
		quest = value
		_build_ui()

var container: VBoxContainer

func _ready():
	if Engine.is_editor_hint():
		_build_ui()

func _build_ui():
	for child in get_children():
		remove_child(child)
		child.queue_free()
	if container:
		remove_child(container)
		container.queue_free()

	container = VBoxContainer.new()
	add_child(container)

	# Set up input port (left side) for quest resource
	set_slot(0, true, 0, Color(1, 1, 1), false, 0, Color(1, 1, 1))

	_add_label("Quest ID", quest.id, "_on_id_changed")
	_add_label("Quest Name", quest.name, "_on_name_changed")
	_add_label("Quest Giver", quest.quest_giver, "_on_giver_changed")
	_add_label("Description", quest.description, "_on_description_changed")
	_add_multiline("Community Board Text", quest.community_board_text, _on_board_text_changed)

	_add_string_array_editor("Unlock On Accept", quest.unlock_on_accept, "_on_unlock_accept_changed")
	_add_string_array_editor("Unlock On Complete", quest.unlock_on_complete, "_on_unlock_complete_changed")

	_add_objective_list_editor()
	_add_resource_rewards_editor()
	add_child(HSeparator.new())

	# Add the on_complete_starts_quest field
	_add_quest_connection_field()

	# Add save button
	_add_save_button()

	# Set up output port (right side) for on_complete_starts_quest
	var last_slot := get_child_count()
	set_slot(last_slot, false, 0, Color(1, 1, 1), true, 0, Color(1, 1, 1))

func _add_label(title: String, initial: String, signal_name: String):
	var hbox = HBoxContainer.new()
	var label = Label.new()
	label.text = title
	hbox.add_child(label)
	var line_edit = LineEdit.new()
	line_edit.text = initial
	line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line_edit.connect("text_changed", Callable(self, signal_name))
	hbox.add_child(line_edit)
	container.add_child(hbox)

func _add_multiline(title: String, initial: String, signal_handler: Callable):
	var label = Label.new()
	label.text = title
	container.add_child(label)
	var text_edit = TextEdit.new()
	text_edit.text = initial
	text_edit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_edit.custom_minimum_size = Vector2(200, 100)
	text_edit.connect("text_changed", func(): signal_handler.call(text_edit.get_text()))
	container.add_child(text_edit)

func _add_string_array_editor(title: String, values: Array[String], update_signal: String):
	var section = VBoxContainer.new()
	var label = Label.new()
	label.text = title
	section.add_child(label)

	for val in values:
		var hbox = HBoxContainer.new()
		var line = LineEdit.new()
		line.text = val
		line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(line)
		section.add_child(hbox)
		line.connect("text_changed", Callable(self, update_signal))

	container.add_child(section)

func _add_objective_list_editor():
	var label = Label.new()
	label.text = "Objectives (count: %d)" % quest.objectives.size()
	container.add_child(label)
	# Display only names here for simplicity
	for obj in quest.objectives:
		var row = Label.new()
		row.text = str(obj)
		container.add_child(row)

func _add_resource_rewards_editor():
	var section = VBoxContainer.new()
	var label = Label.new()
	label.text = "Resource Rewards"
	section.add_child(label)

	for resource_type in ResourcesManager.ResourceType.values():
		var hbox = HBoxContainer.new()
		var resource_label = Label.new()
		resource_label.text = ResourcesManager.RESOURCE_TYPE_NAMES[resource_type]
		hbox.add_child(resource_label)

		var spin = SpinBox.new()
		spin.min_value = 0
		spin.max_value = 100
		spin.value = quest.resource_rewards.get(resource_type, 0)
		spin.connect("value_changed", Callable(self, "_on_resource_reward_changed").bind(resource_type))
		hbox.add_child(spin)
		section.add_child(hbox)

	container.add_child(section)

func _add_quest_connection_field():
	var section = VBoxContainer.new()
	var label = Label.new()
	label.text = "Starts Quest On Complete"
	section.add_child(label)

	var quest_label = Label.new()
	if quest.on_complete_starts_quest:
		quest_label.text = quest.on_complete_starts_quest.name
	else:
		quest_label.text = "None"
	quest_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	section.add_child(quest_label)

	container.add_child(section)

func _add_save_button():
	var button = Button.new()
	button.text = "Save Quest"
	button.connect("pressed", Callable(self, "_on_save_pressed"))
	container.add_child(button)

# --- Signal Handlers ---

func _on_id_changed(text): quest.id = text
func _on_name_changed(text): quest.name = text
func _on_giver_changed(text): quest.quest_giver = text
func _on_description_changed(text): quest.description = text
func _on_board_text_changed(text): quest.community_board_text = text
func _on_unlock_accept_changed(_text): _rebuild_unlock("unlock_on_accept")
func _on_unlock_complete_changed(_text): _rebuild_unlock("unlock_on_complete")

func _on_resource_reward_changed(value: float, resource_type):
	quest.resource_rewards[resource_type] = int(value)

# --- Helpers ---
func _rebuild_unlock(field_name: String):
	var section = container.find_child(field_name, true, false)
	var result: Array[String] = []
	for child in section.get_children():
		if child is HBoxContainer:
			var line = child.get_child(0)
			if line is LineEdit:
				result.append(line.text)
	quest.set(field_name, result)

func _get_connection_input_slot(from_node: Node, from_port: int, to_port: int) -> int:
	# Return the input slot index (0) when a connection is made
	return 0

func _get_connection_output_slot(from_port: int, to_node: Node, to_port: int) -> int:
	# Return the last slot index when a connection is made
	return get_child_count() - 1

func _on_connection_request(from_node: Node, from_port: int, to_node: Node, to_port: int) -> void:
	# Handle connection request
	if from_node is QuestEditUi and to_node is QuestEditUi:
		var from_quest: Quest = from_node.quest
		var to_quest: Quest = to_node.quest
		from_quest.on_complete_starts_quest = to_quest
	_build_ui()

func _on_save_pressed():
	if quest and quest.resource_path:
		var error = ResourceSaver.save(quest, quest.resource_path)
		if error == OK:
			print("Quest saved successfully to: ", quest.resource_path)
		else:
			push_error("Failed to save quest: ", error)
	else:
		push_error("Cannot save quest: No resource path set")
