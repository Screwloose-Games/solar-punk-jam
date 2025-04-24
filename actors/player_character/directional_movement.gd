extends Node

@onready var model: Node3D = %Model

var actor: CharacterBody3D

func _ready() -> void:
	actor = owner

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("Move_Left", "Move_Right", "Move_Forward", "Move_Backward")
	var direction := (actor.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		actor.state = actor.SelfState.WALK
		actor.velocity.x = direction.x * actor.SPEED
		actor.velocity.z = direction.z * actor.SPEED
		model.look_at(model.global_position - direction, Vector3.UP)
	else:
		actor.state = actor.SelfState.IDLE
		actor.velocity.x = move_toward(actor.velocity.x, 0, actor.SPEED)
		actor.velocity.z = move_toward(actor.velocity.z, 0, actor.SPEED)
