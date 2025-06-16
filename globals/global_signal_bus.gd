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

# Signals for new QuestStep subclasses
signal quest_trigger_area_entered(area_id: String)
signal item_received(item_id: String)
signal item_given(item_id: String, npc_id: String)
signal resource_given(npc_id: String, resource: ResourcesManager.ResourceType)
signal object_interacted(interact_id: String)

signal community_board_interacted
signal community_board_quest_accepted
signal talked_to(npc: String)
signal activated_build_mode
signal exited_build_mode
signal structure_interacted(structure: String)
signal seed_planted(crop: Crop)
signal player_entered_home
signal seed_ui_shown
signal day_passed
signal quest_objective_completed
signal stopped_raining
signal started_raining
signal rain_barrel_collected
signal compost_collected
signal waste_deposited
signal stairs_travelled
signal scrap_collected
signal crop_harvested(crop_type: Crop.CropType)
signal ui_button_pressed
signal ui_button_hovered
signal daily_summary_continue_clicked
signal food_donated(count: int)

signal world_loaded
signal world_unloaded
