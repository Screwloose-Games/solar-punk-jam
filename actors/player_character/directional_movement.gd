class_name DirectionalMovement
extends Node

enum MovementBasis {
	CAMERA,
	WORLD,
}

@export var movement_basis_type: MovementBasis = MovementBasis.CAMERA:
	set(val):
		movement_basis_type = val
		if movement_basis_type == MovementBasis.CAMERA:
			basis_node = _camera
		else:
			basis_node = owner

@onready var model: Node3D = %Model

@onready var _camera: PhantomCamera3D = %ThirdPersonCamera

var basis_node: Node3D = owner
var actor: Player

func _ready() -> void:
	movement_basis_type = movement_basis_type
	actor = owner

func get_movement_direction(input_direction: Vector2):
	basis_node = get_viewport().get_camera_3d()
	var movement_direction: Vector3 = Vector3(input_direction.x, 0, input_direction.y).normalized()
	var final_direction = Vector3.ZERO
	if movement_direction:
		var transform_basis : Basis = basis_node.global_transform.basis
		var horizontal_basis = transform_basis.orthonormalized().get_rotation_quaternion().get_euler().y
		var rotation_basis = Basis(Vector3.UP, horizontal_basis)
		movement_direction = rotation_basis * movement_direction.normalized()
		final_direction.x = movement_direction.x
		final_direction.z = movement_direction.z
	return final_direction

func get_velocity(delta: float, speed: float):
	var velocity: Vector3 = Vector3.ZERO
	var input_dir := Input.get_vector("Move_Left", "Move_Right", "Move_Forward", "Move_Backward")
	var movement_direction = get_movement_direction(input_dir)
	
	if movement_direction:
		velocity.x = movement_direction.x * actor.speed
		velocity.z = movement_direction.z * actor.speed
	else:
		velocity.x = move_toward(velocity.x, 0, actor.speed)
		velocity.z = move_toward(velocity.z, 0, actor.speed)
	return velocity
