extends Node3D

@onready var navigation_agent_3d: NavigationAgent3D = %NavigationAgent3D

@export var speed: float = 10

var actor: CharacterBody3D

func _ready() -> void:
	actor = owner

func _physics_process(delta: float) -> void:
	#move_to_point(delta, speed)
	pass

func move_to_point(delta, speed):
	var target_position = navigation_agent_3d.get_next_path_position()
	var direction = global_position.direction_to(target_position)

func _input(event: InputEvent) -> void:
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
		#ray_query.collide_with_areas = true
		var result = space.intersect_ray(ray_query)
		navigation_agent_3d.target_position = result.position
		print(result)
