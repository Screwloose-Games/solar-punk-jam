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
		"busy": "kelly_talk",
		"idle": "kelly_talk",
		"quests": []
	},
	"mister": {
		"intro": "mister_intro",
		"busy": "mister_talk",
		"idle": "mister_talk",
		"quests": ["mister_quest1"]
	},
	"mom": {
		"intro": "mom_intro",
		"busy": "mom_talk",
		"idle": "mom_talk",
		"quests": []
	},
	"trin": {
		"intro": "trin_intro",
		"busy": "trin_talk",
		"idle": "trin_talk",
		"quests": []
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

signal game_state_changed


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
		timeline = DIALOGUE_DB[npc_id].intro
	return timeline


func meet_npc(npc_id : String):
	if npc_id in npcs.keys():
		npcs[npc_id].player_met = true
		game_state_changed.emit()


func complete_quest(giver : String):
	if giver in npcs.keys():
		npcs[giver].quest_active = false
		npcs[giver].progress += 1
		game_state_changed.emit()
		print("Progress for NPC %s increased to %d" % [giver, npcs[giver].progress])
