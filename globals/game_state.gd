extends Node

# Database of dialogue timelines for NPCs under various conditions
const DIALOGUE_DB = {
	"board": {
		"intro": "board_intro",
		"busy": "board_busy",
		"idle": "board_idle",
		"quests": ["board_quest1", "board_quest2", "board_quest3"]
	},
	"kelly": {
		"intro": "kelly_intro",
		"talk": "kelly_talk",
	},
	"mister": {
		"intro": "mister_intro",
		"talk": "mister_talk",
	},
	"mom": {
		"intro": "mom_intro",
		"talk": "mom_talk",
	},
	"trin": {
		"intro": "trin_intro",
		"talk": "trin_talk",
	},
}

var world : Dictionary = {
	"happiness": 50,
	"tech_level": 1,
}
var story : Dictionary = {
	"current_act": 1,
}
var npcs : Dictionary = {
	"board": {
		"player_met": false,
		"progress": 0,
		"quest_active": false
	},
	"kelly": {
		"player_met": false,
		"progress": 0,
		"quest_active": false
	},
	"mister": {
		"player_met": false,
		"progress": 0,
		"quest_active": false
	},
	"mom": {
		"player_met": true,
		"progress": 0,
		"quest_active": false
	},
	"trin": {
		"player_met": false,
		"progress": 0,
		"quest_active": false
	},
}


func get_npc_dialogue(npc_id : String) -> String:
	var timeline = ""
	var this_npc = npcs[npc_id]
	if this_npc.player_met:
		if this_npc.quest_active:
			timeline = DIALOGUE_DB[npc_id].busy
		elif this_npc.progress >= DIALOGUE_DB[npc_id].quests.size():
			timeline = DIALOGUE_DB[npc_id].idle
		else:
			this_npc.quest_active = true
			timeline = DIALOGUE_DB[npc_id].quests[this_npc.progress]
	else:
		this_npc.player_met = true
		timeline = DIALOGUE_DB[npc_id].intro
	return timeline


func complete_quest(giver : String):
	if giver in npcs.keys():
		npcs[giver].quest_active = false
		npcs[giver].progress += 1
		print("Progress for NPC %s increased to %d" % [giver, npcs[giver].progress])
