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

signal structure_built(structure : String)
