class_name MouseLook
extends Node

@export var mouse_sensitivity: float = 0.05
@export var active: bool = false

@onready var camera: PhantomCamera3D = get_parent()

var min_yaw: float = 0
var max_yaw: float = 360

var min_pitch: float = -89.9
var max_pitch: float = 50

func activate():
	active = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func deactivate():
	active = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _unhandled_input(event) -> void:
	if not active:
		return
# Trigger whenever the mouse moves.
	if event is InputEventMouseMotion:
		var pcam_rotation_degrees: Vector3
		# Assigns the current 3D rotation of the SpringArm3D node - to start off where it is in the editor.
		pcam_rotation_degrees = camera.get_third_person_rotation_degrees()

		# Change the X rotation.
		pcam_rotation_degrees.x -= event.relative.y * mouse_sensitivity
			
		# Clamp the rotation in the X axis so it can go over or under the target.
		pcam_rotation_degrees.x = clampf(pcam_rotation_degrees.x, min_pitch, max_pitch)

		# Change the Y rotation value.
		pcam_rotation_degrees.y -= event.relative.x * mouse_sensitivity
			
		# Sets the rotation to fully loop around its target, but without going below or exceeding 0 and 360 degrees respectively.
		pcam_rotation_degrees.y = wrapf(pcam_rotation_degrees.y, min_yaw, max_yaw)
			
		# Change the SpringArm3D node's rotation and rotate around its target.
		camera.set_third_person_rotation_degrees(pcam_rotation_degrees)
