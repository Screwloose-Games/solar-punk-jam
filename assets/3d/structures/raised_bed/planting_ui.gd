class_name PlantingUI
extends MarginContainer

@onready var close_button: Button = %CloseButton
@onready var toolbar_item_panel_container: PanelContainer = %ToolbarItemPanelContainer

@export var seeds: Array[Crop]

signal seed_planted(crop: Crop)
signal closed

func _ready() -> void:
	close_button.pressed.connect(closed.emit)
	render_buttons()

func render_buttons():
	for crop in seeds:
		var button_container: SeedButtonContainer = toolbar_item_panel_container.duplicate()
		toolbar_item_panel_container.add_sibling(button_container)
		button_container.visible = true
		button_container.button.pressed.connect(_on_seed_button_pressed.bind(crop))

func _on_seed_button_pressed(crop: Crop):
	if Crop.has_enough():
		seed_planted.emit(crop)
