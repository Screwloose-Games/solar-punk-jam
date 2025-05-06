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

signal quest_started(quest_id : String)
signal quests_changed
signal quest_completed(giver : String)


func _ready() -> void:
	Dialogic.VAR.variable_changed.connect(check_quests)
	EnvironmentManager.UpdatedAvailableResources.connect(update_resources)
	StructureManager.StructureBuilt.connect(update_structures)
	# Global bus toggles
	GlobalSignalBus.talked_to.connect(update_talk)
	GlobalSignalBus.seed_planted.connect(update_crop)
	GlobalSignalBus.community_board_interacted.connect(update_misc.bind("board_met"))
	GlobalSignalBus.activated_build_mode.connect(update_misc.bind("entered_build"))
	GlobalSignalBus.seed_ui_shown.connect(update_misc.bind("entered_plant"))
	GlobalSignalBus.player_entered_home.connect(update_misc.bind("player_entered_home"))


func start_quest(file_name : String):
	var new_quest = load(FILE_PATH % file_name)
	start_quest_resource(new_quest)


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
	if new_structure.structure in STRUCTURE_MAP.keys():
		Dialogic.VAR.set_variable(STRUCTURE_MAP[new_structure.structure], true)
	check_quests()


func update_resources():
	for res_name in RESOURCE_MAP.keys():
		if res_name in EnvironmentManager.current_resources.keys():
			var res_varname = RESOURCE_MAP[res_name]
			if res_varname in Dialogic.VAR.variables():
				var res_value = EnvironmentManager.current_resources[res_name]
				Dialogic.VAR.set_variable(res_varname, res_value)
	check_quests()


func update_crop(crop : Crop):
	match crop.type:
		Crop.CropType.RADISH:
			Dialogic.VAR.crop_radish += 1
	check_quests()


func update_talk(npc_id : String):
	Dialogic.VAR[npc_id + "_met"] = true
	check_quests()


func update_misc(flag : String):
	Dialogic.VAR[flag] = true
	check_quests()


func check_quests(_changes : Dictionary = {}):
	for quest in quests:
		quest.check_progress()


func _on_quest_complete(giver : String):
	print("Quest completed.")
	Dialogic.VAR[giver + "_active"] = false
	quest_completed.emit(giver)
