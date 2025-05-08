extends Node

# levels / menus
signal changed_level
signal title_screen_started
signal credits_screen_started
signal level_started
signal game_paused
signal game_unpaused

signal win_game_requirements_met
signal level_reset
signal set_ending_visibility(show_panel: bool)

# quest-related

signal community_board_interacted
signal community_board_quest_accepted
signal talked_to(npc: String)
signal activated_build_mode
signal structure_interacted(structure) # Structure ID
signal seed_planted(crop: Crop)
signal player_entered_home
signal seed_ui_shown
signal day_passed
