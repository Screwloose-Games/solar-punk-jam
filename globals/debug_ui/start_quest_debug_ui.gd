extends HBoxContainer

const START_QUEST_TEXT = "Start Quest"
const COMPLETE_QUEST_TEXT = "Complete Quest"

@export var quests_directory: String = "res://narrative/quests/"

var all_quests: Array[Quest] = []
var selected_quest: Quest:
	set(val):
		selected_quest = val
		var can_complete = selected_quest.is_active and !selected_quest.is_complete
		if can_complete:
			quest_action_button.text = COMPLETE_QUEST_TEXT
		else:
			quest_action_button.text = START_QUEST_TEXT
		quest_cancel_button.disabled = !can_complete
		quest_action_button.disabled = selected_quest.is_complete
		quest_complete_step_button.disabled = !can_complete

@onready var quest_options_button: OptionButton = %QuestOptions
@onready var quest_action_button: Button = %QuestActionButton
@onready var quest_cancel_button: Button = %QuestCancelButton
@onready var quest_complete_step_button: Button = %QuestCompleteStepButton

func _ready() -> void:
	_load_all_quests_from_directory()

	_populate_quest_options()

	if quest_action_button:
		quest_action_button.pressed.connect(_on_quest_action_button_pressed)
	else:
		push_error("StartQuestButton node not found! Check the node path is correct.")
	quest_options_button.item_selected.connect(_on_quest_selected)
	quest_cancel_button.pressed.connect(_on_cancel_pressed)
	QuestManager.quest_started_res.connect(_on_quest_started)
	QuestManager.quests_changed.connect(_on_quests_changed)
	quest_complete_step_button.pressed.connect(_on_complete_step_pressed)
	if not all_quests.is_empty():
		selected_quest = all_quests[0]

func _on_complete_step_pressed() -> void:
	selected_quest.complete_next_step()

func _on_quests_changed():
	selected_quest = selected_quest

func _load_all_quests_from_directory() -> void:
	all_quests.clear() # Clear any quests from a previous load.
	var dir = DirAccess.open(quests_directory)
	if not dir:
		push_error("Could not open the quests directory: '" +
		quests_directory + "'. Please ensure it exists.")
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and not file_name.ends_with(".import"):
			var resource_path = quests_directory.path_join(file_name)
			var resource = load(resource_path)
			if resource is Quest:
				all_quests.append(resource)
		file_name = dir.get_next()
	print("Successfully loaded ", all_quests.size(), " quests for the debug UI.")

func _on_quest_selected(quest_index: int):
	selected_quest = all_quests[quest_index]

func _on_quest_started(quest: Quest):
	var index = all_quests.find(quest)
	if index != -1:
		quest_options_button.select(index)
		quest_options_button.item_selected.emit(index)

func _on_cancel_pressed():
	QuestManager.cancel_quest(selected_quest)

func _populate_quest_options() -> void:
	quest_options_button.clear()

	if all_quests.is_empty():
		quest_options_button.add_item("No quests found in project")
		quest_options_button.disabled = true
		quest_action_button.disabled = true
		return

	quest_options_button.disabled = false
	quest_action_button.disabled = false

	for i in range(all_quests.size()):
		var quest: Quest = all_quests[i]
		quest_options_button.add_item(quest.name, i)

func _on_quest_action_button_pressed() -> void:
	var selected_id = quest_options_button.get_selected_id()
	if selected_id >= 0 and selected_id < all_quests.size():
		if selected_quest.is_active:
			for step in selected_quest.steps:
				step.set_complete(true)
		else:
			print("Debug UI is starting quest: '", selected_quest.name, "'")
			QuestManager.start_quest_resource(selected_quest)
	else:
		print("No valid quest selected in the debug UI.")
