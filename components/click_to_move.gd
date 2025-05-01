class_name ClickToMove
extends Node3D

@onready var navigation_agent_3d: NavigationAgent3D = %NavigationAgent3D

@export var speed: float = 10
@export var marker_animation_time: float = 0.5
@export var active = false

var actor: CharacterBody3D

@onready var click_marker: MeshInstance3D = MeshInstance3D.new()


func _ready() -> void:
	add_child(click_marker)
	click_marker.top_level = true
	click_marker.mesh = SphereMesh.new()
	actor = owner
	click_marker.hide()

func animate_click_marker():
	click_marker.scale = Vector3(1, 1, 1)
	click_marker.show()
	var tween := create_tween()
	tween.tween_property(click_marker, "scale", Vector3(0.1, 0.1, 0.1), marker_animation_time)
	tween.finished.connect(click_marker.hide)

func get_velocity(delta: float, speed):
	var target_position = navigation_agent_3d.get_next_path_position()
	var direction = global_position.direction_to(target_position)
	if navigation_agent_3d.is_navigation_finished():
		return Vector3.ZERO
	if not navigation_agent_3d.is_target_reachable():
		return Vector3.ZERO
	return direction * speed

func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return
	if Input.is_action_just_pressed("Left_Click"):
		var camera = get_viewport().get_camera_3d()
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_length = 100
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * ray_length
		var space = get_world_3d().direct_space_state
		var ray_query = PhysicsRayQueryParameters3D.new()
		ray_query.from = from
		ray_query.to = to
		ray_query.collision_mask
		var result = space.intersect_ray(ray_query)
		if result:
			navigation_agent_3d.target_position = result.position
			click_marker.global_position = result.position
			animate_click_marker()
