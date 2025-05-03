extends Node

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

var quest_values = {
	"board_met": false,
	"board_progress": 0,
	"board_active": false,
	"kelly_met": false,
	"kelly_progress": 0,
	"kelly_active": false,
	"mister_met": false,
	"mister_progress": 0,
	"mister_active": false,
	"mom_met": true,
	"mom_progress": 0,
	"mom_active": false,
	"trin_met": false,
	"trin_progress": 0,
	"trin_active": false,
}

signal game_state_changed
