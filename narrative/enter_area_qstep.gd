extends SignalQuestStep
class_name EnterAreaQuestStep 

@export var area_id : String = "area_id"
@export var start_time_hour : int = 0
@export var end_time_hour : int = 0
@export var margin_of_error_minutes : int = 0


func set_active(val : bool):
	autoload_name = "GlobalSignalBus"
	signal_name = "quest_trigger_area_entered"
	expected_args = [area_id]
	super.set_active(val)


func event_occured():
	var game_time = EnvironmentManager.environment_model.get_in_game_time()
	if start_time_hour == end_time_hour:
		super.event_occured()
	elif game_time.hour >= start_time_hour:
		if (game_time.hour < end_time_hour) or \
		(game_time.hour == end_time_hour and game_time.minute <= margin_of_error_minutes):
			super.event_occured()
