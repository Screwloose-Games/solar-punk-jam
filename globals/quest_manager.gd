extends Node

const QUEST_DIRECTORY := "res://narrative/quests/"
const FILE_EXTENSION := ".tres"

const RESOURCE_MAP = {
	"Electricity": "res_electric",
	"Water": "res_water",
	"Food": "res_food",
	"Waste": "res_waste",
	"Soil": "res_soil",
	"Happiness": "res_happy",
	"Materials": "res_material",
	"Seeds": "res_seed",
}

const STRUCTURE_MAP = {
	5: "built_compost",
	6: "built_hygiene",
	11: "built_rain_barrel",
	12: "built_raised_bed",
	13: "built_vplanter",
	20: "built_donation"
}

var preloaded_quests: Dictionary[String, Quest] = {} # file_name -> Quest
var quests_by_id: Dictionary[String, Quest] = {} # quest_id -> Quest
var quests: Array[Quest] = []
var quest_givers: Array[QuestGiver] = []

signal quest_started(quest_id: String)
signal quests_changed
signal quest_completed(giver: String)

func _ready() -> void:
	# Preload all quests in the directory
	var dir := DirAccess.open(QUEST_DIRECTORY)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if file_name.ends_with(FILE_EXTENSION) and not dir.current_is_dir():
				var quest_path = QUEST_DIRECTORY + file_name
				var quest: Quest = load(quest_path)
				if quest:
					var base_name = file_name.get_basename()
					preloaded_quests[base_name] = quest
					quests_by_id[quest.id] = quest
				else:
					push_warning("Failed to load quest: %s" % quest_path)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		push_error("Failed to open quest directory: %s" % QUEST_DIRECTORY)

	Dialogic.VAR.variable_changed.connect(check_quests)
	EnvironmentManager.UpdatedAvailableResources.connect(update_resources)
	StructureManager.StructureBuilt.connect(update_structures)

func register_quest_giver(quest_giver: QuestGiver):
	quest_givers.append(quest_giver)

func unregister_quest_giver(quest_giver: QuestGiver):
	quest_givers.erase(quest_giver)

func get_quest_giver_by_id(quest_giver_id: String):
	var index = quest_givers.find_custom(func(giver: QuestGiver): return giver.id == quest_giver_id)
	if index == -1:
		return null
	return quest_givers.get(index)

func start_quest(file_name: String):
	if file_name in preloaded_quests:
		start_quest_resource(preloaded_quests[file_name])
	else:
		push_error("Quest not preloaded: %s" % file_name)

func start_quest_by_id(id: String):
	if id in preloaded_quests:
		start_quest_resource(preloaded_quests[id])
	else:
		push_error("Quest not preloaded: %s" % id)

## Unlocks this quest so the player can accept it.
func unlock_quest_by_id(id: String):
	if id in quests_by_id:
		var quest: Quest = quests_by_id[id]
		var quest_giver_id = quest.quest_giver
		var quest_giver: QuestGiver = get_quest_giver_by_id(quest_giver_id)
		if not quest_giver:
			push_error("Quest not preloaded: %s" % quest_giver_id)
			return
		quest_giver.add_quest(quest)
	else:
		push_error("Quest not available: %s" % id)

## Unlocks this quest so the player can accept it.
func unlock_quest_by_filename(filename: String):
	if filename in preloaded_quests:
		var quest: Quest = preloaded_quests[filename]
		var quest_giver_id = quest.quest_giver
		var quest_giver: QuestGiver = get_quest_giver_by_id(quest_giver_id)
		if not quest_giver:
			push_error("Quest not preloaded: %s" % quest_giver_id)
			return
		quest_giver.add_quest(quest)
	else:
		push_error("Quest not available: %s" % filename)

func start_quest_resource(new_quest: Quest):
	quests.append(new_quest)
	new_quest.quest_state_changed.connect(emit_signal.bind("quests_changed"))
	new_quest.quest_completed.connect(_on_quest_complete)
	new_quest.start_quest()
	check_quests()
	quest_started.emit(new_quest.id)
	quests_changed.emit()
	print("Quest started: %s" % new_quest.name)

func update_structures(new_structure):
	if new_structure.structure in STRUCTURE_MAP:
		Dialogic.VAR.set_variable(STRUCTURE_MAP[new_structure.structure], true)
	check_quests()

func update_resources():
	for res_name in RESOURCE_MAP:
		if res_name in EnvironmentManager.current_resources:
			var res_varname = RESOURCE_MAP[res_name]
			if res_varname in Dialogic.VAR.variables():
				var res_value = EnvironmentManager.current_resources[res_name]
				Dialogic.VAR.set_variable(res_varname, res_value)
	check_quests()

func check_quests(_changes: Dictionary = {}):
	for quest in quests:
		quest.check_progress()

func _on_quest_complete(giver: String):
	print("Quest completed.")
	Dialogic.VAR[giver + "_active"] = false
	Dialogic.VAR[giver + "_progress"] += 1
	print("Progress for NPC %s increased to %d" % [giver, Dialogic.VAR[giver + "_progress"]])
	quest_completed.emit(giver)
