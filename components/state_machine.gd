extends Node

enum NpcState {
	WALKING,
	IDLE_SIMPLE, #idle1
	IDLE_BREATHING, #idle2
	IDLE_SITTING_CASUAL,
	WALK_FORWARD,
	WALK_STATIONARY,
	ACKNOWLEDGING,
	COCKY,
	FIDGET_STRETCH,
}

@export var state: NpcState = NpcState.IDLE_BREATHING

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
