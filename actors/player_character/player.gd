class_name Player
extends CharacterBody3D

enum MoveMode {
	DIRECTIONAL,
	CLICK,
}

enum SelfState {
	WALK,
	IDLE,
}

@export var speed = 5.0
@export var JUMP_VELOCITY = 4.5
@export var move_mode: MoveMode = MoveMode.CLICK:
	set(val):
		move_mode = val
		#if click_to_move and directional_movement:
			#match val:
				#MoveMode.CLICK:
					#click_to_move.process_mode = Node.PROCESS_MODE_PAUSABLE
					#directional_movement.process_mode = Node.PROCESS_MODE_DISABLED
				#MoveMode.DIRECTIONAL:
					#click_to_move.process_mode = Node.PROCESS_MODE_DISABLED
					#directional_movement.process_mode = Node.PROCESS_MODE_PAUSABLE
					#
#

@onready var model: Node3D = %Model
@onready var directional_movement: DirectionalMovement = %DirectionalMovement
@onready var click_to_move: ClickToMove = %ClickToMove


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
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
	#else:
	velocity = get_horizontal_velocity(delta)

	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
	if velocity.x or velocity.z:
		state = SelfState.WALK
		model.look_at(model.global_position - velocity, Vector3.UP)
	else:
		state = SelfState.IDLE
	move_and_slide()
