extends Node3D

@onready var environment: CapybaraEnvironment = %Environment

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	environment.is_raining = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
