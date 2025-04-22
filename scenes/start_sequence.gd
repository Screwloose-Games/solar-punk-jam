extends Control

signal next

@onready var margin_container: MarginContainer = %MarginContainer
@onready var continue_button: Button = %ContinueButton
var next_scene: PackedScene = SceneManager.MAIN_LEVEL


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	continue_button.pressed.connect(_on_continue_button_pressed)
	continue_button.grab_focus()
	continue_button.grab_click_focus()
	var prompts: Array[Node] = margin_container.get_children()
	var current_i = 0
	for i in prompts.size():
		prompts[i].show()
		await next
		prompts[i].hide()
	SceneTransitionManager.change_scene_with_transition(next_scene, SceneManager.FADE_TRANSITION)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		next.emit()

func _on_continue_button_pressed():
	next.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
