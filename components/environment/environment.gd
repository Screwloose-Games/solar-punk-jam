extends Node3D
class_name CapybaraEnvironment

@export var current_time_in_game_hours = 12.0
@export var day_length_in_game_hours = 12.0
@export var day_start_in_game_hours = 8.0
@export var day_length_in_seconds = 30.0
@export var twilight_color_gradient: Gradient
@export var sun_energy_curve: Curve
@export var night_length_in_seconds = 1.0
@export var is_paused := false:
	set(value):
		is_paused = value
		if value:
			# TODO when unpausing, resume where left-off, right now it will restart the day
			animate_day()
		else:
			animation_tween.kill()
			
@export var is_raining := false:
	set(value):
		is_raining = value
		$Rain.visible = value
		$Rain/CanvasLayer.visible = value
		
var day_offset: float
func _ready() -> void:
	# Exporting variables in a node is easier than dealing with resources, this overwrites the model with what is exported here
	EnvironmentManager.environment_model.update(current_time_in_game_hours, day_length_in_game_hours, day_start_in_game_hours, day_length_in_seconds, night_length_in_seconds, is_paused)
	EnvironmentManager.force_end_day.connect(end_day)
	day_offset = (current_time_in_game_hours - day_start_in_game_hours) / day_start_in_game_hours
	if not is_paused:
		animate_day(day_offset)

var animation_tween: Tween
func animate_day(start_at=0.0):
	EnvironmentManager.day_cycle_start.emit()
	is_raining = EnvironmentManager.environment_model.is_raining
	$DirectionalLight3DSun.light_energy = 0.0
	$DirectionalLight3DMoon.light_energy = 0.0
	$WorldEnvironment.environment.fog_light_energy = 0.0
	if animation_tween:
		animation_tween.kill()
	animation_tween = create_tween()
	animation_tween.tween_method(set_day_time, start_at, 1.0, day_length_in_seconds*(1.0-start_at))
	animation_tween.tween_callback(animate_night)

func end_day():
	if EnvironmentManager.environment_model.is_daytime:
		EnvironmentManager.environment_model.is_daytime = false
		if animation_tween:
			animation_tween.kill()
		animation_tween = create_tween()
		animation_tween.tween_method(set_day_time, EnvironmentManager.environment_model.offset, 1.0, min(day_length_in_seconds*(1.0-EnvironmentManager.environment_model.offset), night_length_in_seconds))
		animation_tween.tween_callback(animate_night)

func animate_night(start_at=0.0):
	EnvironmentManager.day_cycle_end.emit()
	$DirectionalLight3DSun.light_energy = 0.0
	$DirectionalLight3DMoon.light_energy = 1.0
	$WorldEnvironment.environment.fog_light_energy = 0.0
	if animation_tween:
		animation_tween.kill()
	animation_tween = create_tween()
	animation_tween.tween_method(set_night_time, start_at, 1.0, night_length_in_seconds*(1.0-start_at))
	animation_tween.tween_callback(animate_day)


func set_day_time(time: float):
	EnvironmentManager.day_cycle_update.emit(time)
	$DirectionalLight3DSun.rotation.y = lerp_angle(-PI*.5, PI*.5, time+1)
	$DirectionalLight3DMoon.rotation.y = lerp_angle(-PI*.5, PI*.5, time+1)
	$DirectionalLight3DSun.light_energy = sun_energy_curve.sample(time)
	$DirectionalLight3DMoon.light_energy = 1.0 - $DirectionalLight3DSun.light_energy
	$DirectionalLight3DSun.light_color = twilight_color_gradient.sample(time)
	if is_raining:
		$DirectionalLight3DSun.light_energy *= 0.33
		$WorldEnvironment.environment.background_energy_multiplier = 0.5
	else:
		$WorldEnvironment.environment.background_energy_multiplier = max(0.5 + $DirectionalLight3DSun.light_energy * 0.5, $DirectionalLight3DMoon.light_energy)
	$WorldEnvironment.environment.fog_light_energy = $DirectionalLight3DSun.light_energy
	
func set_night_time(time: float):
	EnvironmentManager.day_cycle_update.emit(time)
	$DirectionalLight3DMoon.rotation.y = lerp_angle(-PI*.5, PI*.5, time)
	if is_raining:
		$WorldEnvironment.environment.background_energy_multiplier = 0.5
	else:
		$WorldEnvironment.environment.background_energy_multiplier = 1.0
	
