extends Control

@export var tween_duration := 0.4
@export var offset_y := 200  # How far below it should start/end when hidden

@onready var tween := get_tree().create_tween()
@onready var toolbar_background_panel_container: PanelContainer = %ToolbarBackgroundPanelContainer

var base_position: Vector2

func _ready():
	await get_tree().process_frame
	base_position = toolbar_background_panel_container.position  # This is your visible position (on-screen)
	base_position.x = -toolbar_background_panel_container.size.x / 2.0
	hide_with_slide()
	visible = false

func show_with_slide():
	visible = true
	tween.kill()
	tween = create_tween()
	tween.tween_property(toolbar_background_panel_container, "position", base_position, tween_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func hide_with_slide():
	tween.kill()
	tween = create_tween()
	tween.tween_property(toolbar_background_panel_container, "position", base_position + Vector2(0, offset_y), tween_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(func(): visible = false)
