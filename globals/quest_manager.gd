extends Node

const FILE_PATH = "res://narrative/quests/%s.tres"
const RESOURCE_MAP = {
	"Electricity" : "res_electric",
	"Water" : "res_water",
	"Food" : "res_food",
	"Waste" : "res_waste",
	"Soil" : "res_soil",
	"Happiness" : "res_happy",
	"Materials" : "res_material",
	"Seeds" : "res_seed",
}
const STRUCTURE_MAP = {
	5 : "built_compost",
	6 : "built_hygiene",
	13 : "built_rain_barrel",
	14 : "built_raised_bed",
	22 : "built_donation"
}
var quests : Array[Quest] = []

signal quests_changed


func _ready() -> void:
	Dialogic.VAR.variable_changed.connect(check_quests)
	EnvironmentManager.UpdatedAvailableResources.connect(update_resources)
	StructureManager.StructureBuilt.connect(update_structures)


func start_quest(file_name : String):
	var new_quest = load(FILE_PATH % file_name)
	start_quest_resource(new_quest)

func start_quest_resource(new_quest: Quest):
	quests.append(new_quest)
	new_quest.quest_state_changed.connect(emit_signal.bind("quests_changed"))
	new_quest.quest_completed.connect(_on_quest_complete)
	new_quest.start_quest()
	check_quests()
	quests_changed.emit()
	print("Quest started: %s" % new_quest.name)


func update_structures(new_structure):
	if new_structure.structure in STRUCTURE_MAP.keys():
		Dialogic.VAR.set_variable(STRUCTURE_MAP[new_structure.structure], true)
	check_quests()


func update_resources():
	for res_name in RESOURCE_MAP.keys():
		if res_name in EnvironmentManager.current_resources.keys():
			var res_value = EnvironmentManager.current_resources[res_name]
			var res_varname = RESOURCE_MAP[res_name]
			Dialogic.VAR.set_variable(res_varname, res_value)
	check_quests()


func check_quests(_changes : Dictionary = {}):
	for quest in quests:
		quest.check_progress()


func _on_quest_complete(giver : String):
	print("Quest completed.")
	Dialogic.VAR[giver + "_active"] = false
	Dialogic.VAR[giver + "_progress"] += 1
	print("Progress for NPC %s increased to %d" % [giver, Dialogic.VAR[giver + "_progress"]])
	quests_changed.emit()
