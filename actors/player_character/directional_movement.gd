class_name DirectionalMovement
extends Node

@onready var model: Node3D = %Model

@onready var _camera: PhantomCamera3D = %PlayerPhantomCamera3D


var actor: Player

func _ready() -> void:
	actor = owner

func get_velocity_third_person(delta: float, speed: float):
	var velocity: Vector3 = Vector3.ZERO
	var input_dir := Input.get_vector("Move_Left", "Move_Right", "Move_Forward", "Move_Backward")
	var direction: Vector3 = Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	if direction:
		var camera_basis : Basis = _camera.global_transform.basis
		var horizontal_basis = camera_basis.orthonormalized().get_rotation_quaternion().get_euler().y
		var rotation_basis = Basis(Vector3.UP, horizontal_basis)
		direction = rotation_basis * direction.normalized()
		var move_dir: Vector3 = Vector3.ZERO
		move_dir.x = direction.x
		move_dir.z = direction.z
		velocity.x = move_dir.x * actor.speed
		velocity.z = move_dir.z * actor.speed
	else:
		velocity.x = move_toward(velocity.x, 0, actor.speed)
		velocity.z = move_toward(velocity.z, 0, actor.speed)
	return velocity

func get_velocity(delta: float, speed: float):
	return get_velocity_third_person(delta, speed)
	var velocity: Vector3 = Vector3.ZERO
	var input_dir := Input.get_vector("Move_Left", "Move_Right", "Move_Forward", "Move_Backward")
	var direction := (actor.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		model.look_at(model.global_position - direction, Vector3.UP)
	return velocity
