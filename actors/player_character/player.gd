class_name Player
extends CharacterBody3D

@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5

@onready var model: Node3D = %Model

enum SelfState {
	WALK,
	IDLE,
}

var state: SelfState = SelfState.IDLE

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("Move_Left", "Move_Right", "Move_Forward", "Move_Backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		state = SelfState.WALK
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		model.look_at(model.global_position - direction, Vector3.UP)
	else:
		state = SelfState.IDLE
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
