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
	11 : "built_rain_barrel",
	12 : "built_raised_bed",
	13 : "built_vplanter",
	20 : "built_donation"
}
const TUTORIALS = ["a1d1_trin"]

var quests : Array[Quest] = []
var quest_markers: Array[QuestMarker3D] = []
var unlocked_quests : Array[Quest] = []

signal quest_started(quest_id : String)
signal quests_changed
signal quest_completed(giver : String)
signal structure_built(name : String)
signal crop_planted(name : String)


func _ready() -> void:
	Dialogic.VAR.variable_changed.connect(check_quests)
	# Signals that need to be 'digested' to simplify the argument they pass
	EnvironmentManager.UpdatedAvailableResources.connect(update_resources)
	StructureManager.StructureBuilt.connect(update_structures)
	GlobalSignalBus.seed_planted.connect(update_crop)
	unlock_quest("a1d1_trin")
	GlobalSignalBus.world_unloaded.connect(_on_world_unloaded)

func _on_world_unloaded():
	reset()

func reset():
	quests.clear()
	quest_markers.clear()
	unlocked_quests.clear()
	Dialogic.VAR.clear_game_state()

func unlock_quest(quest_id : String):
	var new_quest = load(FILE_PATH % ("qst_" + quest_id))
	unlocked_quests.append(new_quest)
	quests_changed.emit()


func start_quest(file_name : String):
	var new_quest = load(FILE_PATH % file_name)
	start_quest_resource(new_quest)


func start_quest_resource(new_quest: Quest):
	quests.append(new_quest)
	for quest in unlocked_quests:
		if quest.id == new_quest.id:
			unlocked_quests.erase(quest)
	new_quest.quest_state_changed.connect(emit_signal.bind("quests_changed"))
	new_quest.quest_completed.connect(_on_quest_complete)
	new_quest.start_quest()
	check_quests()
	quest_started.emit(new_quest.id)
	quests_changed.emit()
	print("Quest started: %s" % new_quest.name)


func update_structures(new_structure):
	if new_structure.structure in STRUCTURE_MAP.keys():
		var structure_name = STRUCTURE_MAP[new_structure.structure]
		var success = Dialogic.VAR.set_variable(structure_name, true)
		if not success:
			push_error("Tried setting non-existant variable")
	structure_built.emit(StructureManager.get_structure_name(new_structure.structure))
	check_quests()


func update_crop(crop : Crop):
	match crop.name:
		"Radish":
			Dialogic.VAR.crop_radish += 1
	crop_planted.emit(crop.name)
	check_quests()


func update_resources():
	for res_name in RESOURCE_MAP.keys():
		if res_name in EnvironmentManager.current_resources.keys():
			var res_varname = RESOURCE_MAP[res_name]
			if res_varname in Dialogic.VAR.variables():
				var res_value = EnvironmentManager.current_resources[res_name]
				Dialogic.VAR.set_variable(res_varname, res_value)
	check_quests()


func check_quests(_changes : Dictionary = {}):
	for quest in quests:
		quest.check_progress()


func _on_quest_complete(giver : String):
	print("Quest completed.")
	Dialogic.VAR[giver + "_active"] = false
	quests_changed.emit()
	quest_completed.emit(giver)

func get_quest_markers_by_id(id: String) -> Array[QuestMarker3D]:
	var markers: Array[QuestMarker3D]
	var nodes: Array[Node] = get_tree().get_nodes_in_group("QuestMarker")
	markers.append_array(nodes)
	markers = markers.filter(func(marker: QuestMarker3D): return marker.id == id)
	return markers
