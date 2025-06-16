# GO_TO quest step
# Used when the player must go to a certain area in the game world
# Optional: When the player has to be at the area at a certain time in the game
extends QuestStep
class_name QuestStepGoTo

@export var area_id: String = "area_id"
@export_group("Start Time", "start_")
@export_range(0, 23) var start_hour : int = 0
@export_range(0, 59) var start_minute : int = 0
@export_group("End Time", "end_")
@export_range(0, 23) var end_hour : int = 0
@export_range(0, 59) var end_minute : int = 0
@export_group("")
@export_range(0, 59) var grace_period_minutes : int = 0


func set_active(val: bool):
	_signal = GlobalSignalBus.quest_trigger_area_entered
	_expected_args = [area_id]
	super.set_active(val)


func event_occured():
	var game_time = EnvironmentManager.environment_model.get_in_game_time()
	var game_time_minutes = (game_time.hour * 60) + game_time.minute
	var start_time_minutes = int(start_hour * 60) + start_minute
	var end_time_minutes = int(end_hour * 60) + end_minute + grace_period_minutes
	if start_time_minutes == end_time_minutes:
		super.event_occured()
	elif game_time_minutes >= start_time_minutes and game_time_minutes <= end_time_minutes:
		super.event_occured()
