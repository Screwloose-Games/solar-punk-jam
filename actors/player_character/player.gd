class_name Player
extends CharacterBody3D

enum MoveMode {
	DIRECTIONAL,
	CLICK,
}

enum CameraMode {
	STATIC,
	ORBIT,
}

enum SelfState {
	WALK,
	IDLE,
}

@export var camera_mode: CameraMode = CameraMode.STATIC:
	set(val):
		camera_mode = val
		match camera_mode:
			CameraMode.STATIC:
				mouse_look.deactivate()
			CameraMode.ORBIT:
				mouse_look.activate()
		
@export var rotation_duration: float = 0.2
@export var speed = 5.0
@export var JUMP_VELOCITY = 4.5
@export var move_mode: MoveMode = MoveMode.CLICK:
	set(val):
		move_mode = val

@onready var model: Node3D = %Model
@onready var directional_movement: DirectionalMovement = %DirectionalMovement
@onready var click_to_move: ClickToMove = %ClickToMove
@onready var mouse_look: MouseLook = %MouseLook

var state: SelfState = SelfState.IDLE

func _ready() -> void:
	move_mode = move_mode

func get_horizontal_velocity(delta: float):
	match move_mode:
		MoveMode.DIRECTIONAL:
			return directional_movement.get_velocity(delta, speed)
		MoveMode.CLICK:
			return click_to_move.get_velocity(delta, speed)
	return click_to_move.get_velocity(delta, speed)
		
func _physics_process(delta: float) -> void:
	velocity = get_horizontal_velocity(delta)
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	
	if horizontal_velocity.length_squared() > 0.01:
		state = SelfState.WALK
		var direction = horizontal_velocity.normalized()
		var target_basis = Basis.looking_at(-direction, Vector3.UP)
		model.basis = model.basis.slerp(target_basis, 1.0 / rotation_duration * delta)

	else:
		state = SelfState.IDLE
	
	move_and_slide()
