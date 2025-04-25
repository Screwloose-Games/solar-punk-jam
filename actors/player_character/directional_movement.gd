class_name DirectionalMovement
extends Node

@onready var model: Node3D = %Model

var actor: CharacterBody3D

func _ready() -> void:
	actor = owner

func get_velocity(delta: float, speed: float):
	var velocity: Vector3 = Vector3.ZERO
	var input_dir := Input.get_vector("Move_Left", "Move_Right", "Move_Forward", "Move_Backward")
	var direction := (actor.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		model.look_at(model.global_position - direction, Vector3.UP)
	return velocity
	#else:
		#
		#velocity.x = move_toward(actor.velocity.x, 0, speed)
		#velocity.z = move_toward(actor.velocity.z, 0, speed)
