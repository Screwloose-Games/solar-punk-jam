@tool
class_name QuestStepEditUi
extends VBoxContainer

@export var quest_step : QuestStep:
	set(value):
		quest_step = value
		_build_ui()

func _build_ui():
	# Clear existing children
	for child in get_children():
		remove_child(child)
		child.queue_free()

	add_child(_make_line_edit("Description", quest_step.description, func(val): quest_step.description = val))
	add_child(_make_int_field("Goal", quest_step.goal, func(val): quest_step.goal = val))
	add_child(_make_array_editor("Prerequisites", quest_step.prerequisites, func(val): quest_step.prerequisites = val))
	add_child(_make_line_edit("Play Dialogue", quest_step.play_dialogue, func(val): quest_step.play_dialogue = val))
	add_child(_make_option_menu("Marker ID", quest_step.marker_id, func(val): quest_step.marker_id = val, [
		"trin", "mom", "home_entrance", "mister", "material_location",
		"board", "water", "trin_garden", "home_roof_garden", "go_to_bed_door",
		"trin_compost", "trin_water", "community_food_stand", "vertical_garden"
	]))

	# Detect subtype and add subtype-specific UI
	if quest_step is SignalQuestStep:
		_add_signal_objective_fields(quest_step)
	elif quest_step is ValueQuestStep:
		_add_value_objective_fields(quest_step)

func _add_signal_objective_fields(obj: SignalQuestStep):
	add_child(_make_option_menu("Autoload", obj.autoload_name, func(val): obj.autoload_name = val, [
		"GlobalSignalBus", "QuestManager", "EnvironmentManager"
	]))
	add_child(_make_line_edit("Signal Name", obj.signal_name, func(val): obj.signal_name = val))
	add_child(_make_array_editor("Expected Args", obj.expected_args, func(val): obj.expected_args = val))

func _add_value_objective_fields(obj: ValueQuestStep):
	add_child(_make_line_edit("Target Value", obj.target_value, func(val): obj.target_value = val))

# UI Field Helpers

func _make_line_edit(label_text: String, initial_value: String, setter: Callable) -> Control:
	var hbox = HBoxContainer.new()
	hbox.name = label_text + "_hbox"
	var lbl = Label.new()
	lbl.name = label_text + "_label"
	lbl.set_text(label_text + ":")
	hbox.add_child(lbl)
	var input = LineEdit.new()
	input.name = label_text + "_input"
	input.text = initial_value
	input.text_changed.connect(setter)
	hbox.add_child(input)
	return hbox

func _make_int_field(label_text: String, initial_value: int, setter: Callable) -> Control:
	var hbox = HBoxContainer.new()
	hbox.name = label_text + "_hbox"
	var lbl = Label.new()
	lbl.name = label_text + "_label"
	lbl.set_text(label_text + ":")
	hbox.add_child(lbl)
	var spin = SpinBox.new()
	spin.name = label_text + "_spin"
	spin.min_value = 0
	spin.value = initial_value
	spin.value_changed.connect(setter)
	hbox.add_child(spin)
	return hbox

func _make_array_editor(label_text: String, initial_array: Array, setter: Callable) -> Control:
	var vbox = VBoxContainer.new()
	vbox.name = label_text + "_vbox"
	var lbl = Label.new()
	lbl.name = label_text + "_label"
	lbl.set_text(label_text + ": (Array)")
	vbox.add_child(lbl)
	# This is a placeholder—replace with your own array editor logic
	for value in initial_array:
		var label = Label.new()
		label.text = str(value)
		vbox.add_child(label)
	return vbox

func _make_option_menu(label_text: String, selected_value: String, setter: Callable, options: Array[String]) -> Control:
	var hbox = HBoxContainer.new()
	hbox.name = label_text + "_hbox"
	var lbl = Label.new()
	lbl.name = label_text + "_label"
	lbl.set_text(label_text + ":")
	hbox.add_child(lbl)
	var menu = OptionButton.new()
	menu.name = label_text + "_menu"
	for opt in options:
		menu.add_item(opt)
	menu.selected = options.find(selected_value)
	menu.item_selected.connect(func(index): setter.call(options[index]))
	hbox.add_child(menu)
	return hbox
