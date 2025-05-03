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
	13 : "built_rain_barrel",
	14 : "built_raised_bed"
}
var quests : Array[Quest] = []

signal npc_notified_new(npc_id)
signal quests_changed


func _ready() -> void:
	Dialogic.VAR.variable_changed.connect(check_quests)
	EnvironmentManager.UpdatedAvailableResources.connect(update_resources)
	StructureManager.StructureBuilt.connect(update_structures)


func start_quest(file_name : String):
	var new_quest = load(FILE_PATH % file_name)
	quests.append(new_quest)
	new_quest.quest_state_changed.connect(emit_signal.bind("quests_changed"))
	new_quest.quest_completed.connect(_on_quest_complete)
	new_quest.start_quest()
	quests_changed.emit()
	print("Quest started: %s" % new_quest.name)


func update_structures(new_structure):
	if new_structure.structure in STRUCTURE_MAP.keys():
		Dialogic.VAR.set_variable(STRUCTURE_MAP[new_structure.structure], true)
	check_quests()


func update_resources():
	check_quests()


func check_quests(_changes : Dictionary = {}):
	for quest in quests:
		quest.check_progress()


func _on_quest_complete(giver : String):
	print("Quest completed.")
	Dialogic.VAR[giver + "_progress"] += 1
	print("Progress for NPC %s increased to %d" % [giver, Dialogic.VAR[giver + "_progress"]])
	npc_notified_new.emit(giver)
	quests_changed.emit()
