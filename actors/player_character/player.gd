class_name Player
extends CharacterBody3D

enum MoveMode {
	DIRECTIONAL,
	CLICK,
	NONE,
}

enum PlayerMode {
	TRAVEL,
	BUILD,
}

enum CameraMode {
	THIRD_PERSON,
	ISOMETRIC,
}

enum SelfState {
	WALK,
	IDLE,
}

@export var allow_player_input: bool = true:
	set(val):
		allow_player_input = val
		if not interact_canvas_layer:
			await ready
		interact_canvas_layer.visible = allow_player_input

@export var cutscene_mode_enabled: bool = false:
	set(val):
		cutscene_mode_enabled = val
		allow_player_input = !cutscene_mode_enabled
		if !cutscene_mode_enabled:
			player_mode = PlayerMode.TRAVEL

@export var camera_mode: CameraMode = CameraMode.THIRD_PERSON:
	set(val):
		camera_mode = val
		match camera_mode:
			CameraMode.ISOMETRIC:
				if not isometric_camera:
					return
				change_camera_priority(isometric_camera)
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			CameraMode.THIRD_PERSON:
				if not third_person_camera:
					return
				change_camera_priority(third_person_camera)
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
@export var move_mode: MoveMode = MoveMode.DIRECTIONAL:
	set(val):
		move_mode = val
		match move_mode:
			MoveMode.DIRECTIONAL:
				click_to_move.process_mode = Node.PROCESS_MODE_DISABLED
				click_to_move.active = false
			MoveMode.CLICK:
				click_to_move.process_mode = Node.PROCESS_MODE_INHERIT
				click_to_move.active = true

@export var rotation_duration: float = 0.2
@export var speed = 5.0
@export var JUMP_VELOCITY = 4.5

@onready var model: Node3D = %Model
@onready var directional_movement: DirectionalMovement = %DirectionalMovement
@onready var click_to_move: ClickToMove = %ClickToMove

@onready var isometric_camera: PhantomCamera3D = %IsometricCamera
@onready var third_person_camera: PhantomCamera3D = %ThirdPersonCamera

@onready var interact_area_3d: InteractArea3D = %InteractArea3D
@onready var build_area_3d: InteractArea3D = %BuildArea3D
@onready var interact_canvas_layer: CanvasLayer = %InteractCanvasLayer

@onready var hud_canvas_layer: HUDCanvasLayer = %HUDCanvasLayer


var is_interacting: bool:
	get:
		return interact_area_3d.is_interacting or build_area_3d.is_interacting

var state: SelfState = SelfState.IDLE

var player_mode: PlayerMode = PlayerMode.TRAVEL:
	set(val):
		player_mode = val
		match player_mode:
			PlayerMode.TRAVEL:
				camera_mode = CameraMode.THIRD_PERSON
				move_mode = MoveMode.DIRECTIONAL
				if hud_canvas_layer:
					hud_canvas_layer.hide_build_tray()
			PlayerMode.BUILD:
				GlobalSignalBus.activated_build_mode.emit()
				camera_mode = CameraMode.ISOMETRIC
				move_mode = MoveMode.NONE
				if hud_canvas_layer:
					hud_canvas_layer.show_build_tray()

func _ready() -> void:
	move_mode = move_mode
	camera_mode = camera_mode
	player_mode = player_mode
	build_area_3d.started_interacting.connect(_on_started_building)
	build_area_3d.stopped_interacting.connect(_on_stopped_building)
	
func _on_started_building():
	interact_canvas_layer.hide()
	player_mode = PlayerMode.BUILD
	
func _on_stopped_building():
	player_mode = PlayerMode.TRAVEL
	interact_canvas_layer.show()

func change_camera_priority(priority_camera: PhantomCamera3D):
	var all_cams = PhantomCameraManager.get_phantom_camera_3ds()
	for cam:PhantomCamera3D in all_cams:
		cam.set_priority(0)
	priority_camera.priority = 10

func get_horizontal_velocity(delta: float) -> Vector3:
	if is_interacting:
		return Vector3.ZERO
	match move_mode:
		MoveMode.DIRECTIONAL:
			return directional_movement.get_velocity(delta, speed)
		MoveMode.CLICK:
			return click_to_move.get_velocity(delta, speed)
		MoveMode.NONE:
			return Vector3.ZERO
	return Vector3.ZERO

func handle_build_mode():
	var input_direction: Vector2 = Input.get_vector("Move_Left", "Move_Right", "Move_Forward", "Move_Backward")
	if input_direction != Vector2.ZERO:
		player_mode = PlayerMode.TRAVEL
		build_area_3d.is_interacting = false
		

func _physics_process(delta: float) -> void:
	if not allow_player_input:
		return
	velocity = get_horizontal_velocity(delta)
	
	if player_mode == PlayerMode.BUILD:
		handle_build_mode()
	
	if not is_on_floor():
		var gravity = get_gravity()
		velocity += gravity

	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	
	if horizontal_velocity.length_squared() > 0.01:
		state = SelfState.WALK
		var direction = horizontal_velocity.normalized()
		var target_basis = Basis.looking_at(-direction, Vector3.UP)
		model.basis = model.basis.slerp(target_basis, 1.0 / rotation_duration * delta)

	else:
		state = SelfState.IDLE
	
	move_and_slide()
