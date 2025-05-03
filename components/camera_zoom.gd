extends Node

@export var zoom_speed: float = 2.0
@export var min_zoom: float = 0.0
@export var max_zoom: float = 10.0

@onready var camera: PhantomCamera3D = get_parent()

var zoom_distance: float = 10.0

func _ready() -> void:
	await camera.ready
	camera.spring_length = zoom_distance

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_distance = max(min_zoom, zoom_distance - zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_distance = min(max_zoom, zoom_distance + zoom_speed)
		camera.set_spring_length(zoom_distance)
		var new_offset = camera.follow_offset
		new_offset.z = zoom_distance
		camera.spring_length = zoom_distance
