extends Control

signal next

@onready var continue_button: Button = %ContinueButton
@onready var label: Label = %Label

@export_multiline var text_panels: PackedStringArray = []
var next_scene: PackedScene = SceneManager.MAIN_LEVEL

var current_index: int = 0

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_button_pressed)
	continue_button.grab_focus()
	continue_button.grab_click_focus()
	_show_next_text()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		next.emit()

func _on_continue_button_pressed() -> void:
	next.emit()

func _show_next_text():
	if current_index < text_panels.size():
		label.text = text_panels[current_index]
		await next
		current_index += 1
		_show_next_text()
	else:
		SceneTransitionManager.change_scene_with_transition(next_scene, SceneManager.FADE_TRANSITION)
