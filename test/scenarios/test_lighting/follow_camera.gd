extends Camera3D

@export var target: Node3D
@export var lerp_speed: float = 5.0
@export var shake_intensity_multiplier: float = 1.0  # Intensity of the shake
@export var shake_frequency: float = 10.0  # Frequency of the shake

var shake_intensity: float:
	set(val):
		shake_intensity = val * shake_intensity_multiplier

var starting_transform: Vector3
var look_rotation: float

# Variables for camera shake
var shake_timer: float = 0.0
var shake_duration: float = 0.5
var shake_offset: Vector3 = Vector3.ZERO


func _ready() -> void:
	starting_transform = global_position - target.global_position


func _process(delta: float) -> void:
	# Update shake offset
	if shake_timer > 0.0:
		shake_timer -= delta
		var shake_factor = shake_timer / shake_duration
		shake_offset = (
			Vector3(randf() * 2 - 1, randf() * 2 - 1, randf() * 2 - 1)
			* shake_intensity
			* shake_factor
		)
	else:
		shake_offset = Vector3.ZERO

	# Smoothly follow the target
	var target_position = (
		target.global_position + starting_transform - Vector3(0, v_offset, 0) + shake_offset
	)
	global_position = global_position.lerp(target_position, lerp_speed * delta)

func get_look_rotation() -> float:
	return look_rotation


func shake_camera(intensity: float) -> void:
	shake_timer = shake_duration
	# Remap intensity between 0.5 and 1
	shake_intensity = lerp(0.5, 1.0, intensity)


func convert_health_to_shake_intensity(missing_health: int, max_health: int) -> float:
	var health_ratio = float(missing_health) / float(max_health)

	return shake_intensity * health_ratio


func _on_health_component_took_damage(amount: int) -> void:
	pass
