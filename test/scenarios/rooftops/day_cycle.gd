extends Node3D

@export var is_raining := false
@export var do_update := true
@export var preset_time := 0.75

func set_time(time: float):
	$DirectionalLight3DMoon.rotation.y = lerp_angle(PI*.5, -PI*.5, time*2) + TAU
	$DirectionalLight3DMoon.light_energy = max(0.1,sin(time*PI*2)+0.1)
	$DirectionalLight3DSun.rotation.y = lerp_angle(PI*.5, -PI*.5, time*2)
	$DirectionalLight3DSun.light_energy = max(0.0,-sin(time*PI*2)+0.1)
	if is_raining:
		$DirectionalLight3DSun.light_energy *= 0.33
		$"../WorldEnvironment".environment.background_energy_multiplier = 0.5
		$DirectionalLight3DTwilight.light_energy = 0.0
	else:
		$DirectionalLight3DTwilight.light_energy = max(0.0, 1.0 - $DirectionalLight3DSun.light_energy - $DirectionalLight3DMoon.light_energy) * 0.33
		$"../WorldEnvironment".environment.background_energy_multiplier = 0.5 + $DirectionalLight3DSun.light_energy * 0.5
	$"../WorldEnvironment".environment.fog_light_energy = $DirectionalLight3DSun.light_energy
	
@export var duration = 3.0
func _ready() -> void:
	if do_update:
		animate_cycle()
	else:
		set_time(preset_time)
	
func animate_cycle():
	var tween = create_tween()
	tween.tween_method(set_time, 0.0, 1.0, duration)
	tween.tween_callback(animate_cycle)
	
