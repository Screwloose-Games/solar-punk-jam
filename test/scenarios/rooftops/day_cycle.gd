extends Node3D

func set_time(time: float):
	$DirectionalLight3DMoon.rotation.y = lerp_angle(PI*.5, -PI*.5, time*2) + TAU
	$DirectionalLight3DMoon.light_energy = max(0.0,sin(time*PI*2)+0.1)
	$DirectionalLight3DSun.rotation.y = lerp_angle(PI*.5, -PI*.5, time*2)
	$DirectionalLight3DSun.light_energy = max(0.0,-sin(time*PI*2)+0.1)

	
@export var duration = 3.0
func _ready() -> void:
	animate_cycle()
	
func animate_cycle():
	var tween = create_tween()
	tween.tween_method(set_time, 0.0, 1.0, duration)
	tween.tween_callback(animate_cycle)
	
