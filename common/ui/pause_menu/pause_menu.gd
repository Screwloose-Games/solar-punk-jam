extends CanvasLayer

@onready var continue_button = %ContinueButton
@onready var options_button = %OptionsButton
@onready var main_menu_button = %MainMenuButton
@onready var pause_menu_body = %PauseMenuBody
@onready var quit_button: Button = %QuitButton
@onready var respawn_button: Button = %RespawnButton

var main_menu_scene: PackedScene = SceneManager.MAIN_MENU
var options_menu_scene: PackedScene = SceneManager.OPTIONS_MENU


func _ready():
	#get_tree().paused = true
	visible = false
	continue_button.pressed.connect(on_continue_pressed)
	main_menu_button.pressed.connect(on_main_menu_pressed)
	options_button.pressed.connect(on_options_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	respawn_button.pressed.connect(_on_respawn_pressed)
	if OS.has_feature("web"):
		quit_button.hide()

func _on_respawn_pressed():
	var player = get_tree().get_first_node_in_group("Player")
	var target = get_tree().get_first_node_in_group("PlayerSpawner")
	if target:
		player.global_position = target.global_position
	unpause()

func _on_quit_button_pressed():
	get_tree().quit(0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause()

func pause():
	var should_pause = !get_tree().paused
	get_tree().paused = should_pause
	visible = should_pause

	if should_pause:
		GlobalSignalBus.game_paused.emit()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		GlobalSignalBus.game_unpaused.emit()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func unpause():
	get_tree().paused = false
	visible = false
	GlobalSignalBus.game_unpaused.emit()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func on_continue_pressed():
	unpause()

func on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_packed(main_menu_scene)

func on_options_pressed():
	var options_menu_instance = options_menu_scene.instantiate()
	options_menu_instance.back_pressed.connect(on_options_back_pressed.bind(options_menu_instance))
	pause_menu_body.visible = false
	add_child(options_menu_instance)


func on_options_back_pressed(options_menu: OptionsMenu):
	pause_menu_body.visible = true
	options_menu.queue_free()
