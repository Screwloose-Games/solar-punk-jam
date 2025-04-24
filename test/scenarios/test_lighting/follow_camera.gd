extends Camera3D

@export var target: Node3D
@export var lerp_speed: float = 5.0
@export var shake_intensity_multiplier: float = 1.0  # Intensity of the shake
@export var shake_frequency: float = 10.0  # Frequency of the shake

@export var zoom_speed: float = 2.0  # Speed of zooming
@export var min_zoom: float = 5.0  # Minimum zoom distance
@export var max_zoom: float = 20.0  # Maximum zoom distance

var shake_intensity: float:
	set(val):
		shake_intensity = val * shake_intensity_multiplier

var starting_transform: Vector3
var look_rotation: float

# Variables for camera shake
var shake_timer: float = 0.0
var shake_duration: float = 0.5
var shake_offset: Vector3 = Vector3.ZERO

var zoom_distance: float = 10.0  # Current zoom distance


func _ready() -> void:
	starting_transform = global_position - target.global_position
	zoom_distance = starting_transform.length()


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
		target.global_position
		+ starting_transform.normalized() * zoom_distance
		- Vector3(0, v_offset, 0)
		+ shake_offset
	)
	global_position = global_position.lerp(target_position, lerp_speed * delta)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_distance = max(min_zoom, zoom_distance - zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_distance = min(max_zoom, zoom_distance + zoom_speed)


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
