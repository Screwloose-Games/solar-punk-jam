extends Area3D

@export var id : String = "area_id"
@export var margin_of_error_minutes : int = 0
@export var start_time_hour : int = 0
@export var end_time_hour : int = 0


func _on_body_entered(body: Node3D) -> void:
	var game_time = EnvironmentManager.environment_model.get_in_game_time()
	if body is Player:
		if start_time_hour == end_time_hour:
			GlobalSignalBus.quest_trigger_area_entered.emit(id)
		elif game_time.hour >= start_time_hour:
			if (game_time.hour < end_time_hour) or \
			(game_time.hour == end_time_hour and game_time.minute <= margin_of_error_minutes):
				GlobalSignalBus.quest_trigger_area_entered.emit(id)
