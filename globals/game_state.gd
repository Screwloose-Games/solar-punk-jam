extends Node

# Database of dialogue timelines for NPCs under various conditions
const DIALOG_DB = {
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
	"kelly": {
		"player_met": false,
		"relationship": 0,
	},
	"mister": {
		"player_met": false,
		"relationship": 0,
	},
	"mom": {
		"player_met": true,
		"relationship": 50,
	},
	"trin": {
		"player_met": false,
		"relationship": 0,
	},
}


func get_npc_dialogue(npc_id : String) -> String:
	var timeline = ""
	if npcs[npc_id].player_met:
		timeline = DIALOG_DB[npc_id].talk
	else:
		npcs[npc_id].player_met = true
		timeline = DIALOG_DB[npc_id].intro
	return timeline
