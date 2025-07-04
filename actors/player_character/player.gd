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
	FIDGET,
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
@export var jump_velocity = 4.5

var is_interacting: bool:
	get:
		var is_player_interacting: bool = (
			interact_area_3d.is_interacting or build_area_3d.is_interacting
		)
		is_player_interacting = is_player_interacting or in_dialogue
		return is_player_interacting

var state: SelfState = SelfState.IDLE
var idle_timer: float = 0.0
var idle_anim_duration: float = 10.0
var fidget_anim_duration: float = 3.8

var in_dialogue: bool = false

var should_ignore_input: bool:
	get:
		return force_ignore_input or is_interacting

var should_ignore_interact: bool:
	get:
		return is_interacting

var force_ignore_input: bool = false

var player_mode: PlayerMode = PlayerMode.TRAVEL:
	set(val):
		player_mode = val
		match player_mode:
			PlayerMode.TRAVEL:
				GlobalSignalBus.exited_build_mode.emit()
				camera_mode = CameraMode.THIRD_PERSON
				move_mode = MoveMode.DIRECTIONAL
				#if hud_canvas_layer:
				#hud_canvas_layer.hide_build_tray()
			PlayerMode.BUILD:
				GlobalSignalBus.activated_build_mode.emit()
				camera_mode = CameraMode.ISOMETRIC
				move_mode = MoveMode.NONE
				#if hud_canvas_layer:
				#hud_canvas_layer.show_build_tray()

@onready var model: Node3D = %Model
@onready var directional_movement: DirectionalMovement = %DirectionalMovement
@onready var click_to_move: ClickToMove = %ClickToMove

@onready var isometric_camera: PhantomCamera3D = %IsometricCamera
@onready var third_person_camera: PhantomCamera3D = %ThirdPersonCamera

@onready var interact_area_3d: InteractArea3D = %InteractArea3D
@onready var build_area_3d: InteractArea3D = %BuildArea3D
@onready var interact_canvas_layer: CanvasLayer = %InteractCanvasLayer

#@onready var hud_canvas_layer: HUDCanvasLayer = %HUDCanvasLayer


func _ready() -> void:
	move_mode = move_mode
	camera_mode = camera_mode
	player_mode = player_mode
	build_area_3d.started_interacting.connect(_on_started_building)
	build_area_3d.stopped_interacting.connect(_on_stopped_building)
	Dialogic.timeline_started.connect(_on_dialogue_started)
	Dialogic.timeline_ended.connect(_on_dialogue_ended)


func _on_dialogue_started():
	in_dialogue = true
	return


func _on_dialogue_ended():
	in_dialogue = false
	return


func _on_started_building():
	interact_canvas_layer.hide()
	player_mode = PlayerMode.BUILD


func _on_stopped_building():
	player_mode = PlayerMode.TRAVEL
	interact_canvas_layer.show()


func change_camera_priority(priority_camera: PhantomCamera3D):
	var all_cams = PhantomCameraManager.get_phantom_camera_3ds()
	for cam: PhantomCamera3D in all_cams:
		cam.set_priority(0)
	priority_camera.priority = 10


func get_horizontal_velocity(delta: float) -> Vector3:
	if should_ignore_input:
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
	var input_direction: Vector2 = Input.get_vector(
		"Move_Left", "Move_Right", "Move_Forward", "Move_Backward"
	)
	if input_direction != Vector2.ZERO:
		player_mode = PlayerMode.TRAVEL
		build_area_3d.is_interacting = false


func set_animation_state(delta: float, is_moving: bool):
	if is_moving:
		state = SelfState.WALK
		idle_timer = 0
	else:  # toggle back and forth between idle and fidget
		idle_timer += delta
		var total_anim_duration = idle_anim_duration + fidget_anim_duration
		if fmod(idle_timer, total_anim_duration) <= idle_anim_duration:
			state = SelfState.IDLE
		else:
			state = SelfState.FIDGET


func _physics_process(delta: float) -> void:
	if not allow_player_input:
		return

	velocity = get_horizontal_velocity(delta)
	var is_moving = false

	if player_mode == PlayerMode.BUILD:
		handle_build_mode()

	if not is_on_floor():
		var gravity = get_gravity()
		velocity += gravity

	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)

	if horizontal_velocity.length_squared() > 0.01:
		is_moving = true
		var direction = horizontal_velocity.normalized()
		var target_basis = Basis.looking_at(-direction, Vector3.UP)
		model.basis = model.basis.slerp(target_basis, 1.0 / rotation_duration * delta)

	set_animation_state(delta, is_moving)

	move_and_slide()
