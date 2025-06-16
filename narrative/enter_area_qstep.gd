class_name EnterAreaQuestStep 
extends SignalQuestStepBase

@export var area_id: String = "area_id"
@export var start_time_hour: float = 0.0
@export var end_time_hour: float = 0.0


func set_active(val: bool):
	_signal = GlobalSignalBus.quest_trigger_area_entered
	_expected_args = [area_id]
	super.set_active(val)


func event_occured():
	var game_time = EnvironmentManager.environment_model.get_in_game_time()
	if start_time_hour == end_time_hour:
		super.event_occured()
	elif game_time.hour >= start_time_hour and game_time.hour < end_time_hour:
		super.event_occured()
