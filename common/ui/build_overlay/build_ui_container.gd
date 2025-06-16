class_name BuildUiContainer
extends MarginContainer



var buildable_structures: Array[BuildableStructure] = []

var unlock_all_structures_from_the_start_for_debugging: bool = false
@onready var structure_panel_container: BuildLineItem = %StructurePanelContainer
@onready var resource_ui_template = %ResourceLabel
@onready var hover_panel: BuildHoverDetailContainer = %HoverPanel


func handle_debug_ready():
	if unlock_all_structures_from_the_start_for_debugging:
		for idx in len(StructureManager.structure_data):
			register_structure_as_hud_icon(idx)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	StructureManager.updated_available_structures.connect(self.refresh_structure_build_palette)
	GlobalSignalBus.activated_build_mode.connect(_on_player_activated_build_mode)
	GlobalSignalBus.exited_build_mode.connect(_on_player_exited_build_mode)
	hover_panel.hide()

func _on_player_activated_build_mode():
	show_build_mode()

func _on_player_exited_build_mode():
	hide_build_mode()

func show_build_mode():
	get_parent().show()
	
func hide_build_mode():
	get_parent().hide()


class BuildableStructure:
	var idx: int
	var ui: Control
	func _init(idx, ui) -> void:
		self.idx = idx
		self.ui = ui

func refresh_structure_build_palette():
	for i in buildable_structures:
		i.ui.queue_free()
	buildable_structures = []
	for idx in StructureManager.available_structures:
		register_structure_as_hud_icon(idx)

func _on_line_item_mouse_entered(idx: int):
	hover_panel.show_preview(idx)
	GlobalSignalBus.ui_button_hovered.emit()
	
	pass

func _on_line_item_mouse_exited(idx: int):
	pass

func register_structure_as_hud_icon(idx):
	
	var requirements_missing = StructureManager.check_structure_requirements(idx)
	var ui: BuildLineItem = structure_panel_container.duplicate()
	if requirements_missing:
		ui.disabled = true
	ui.structure_id = idx
	buildable_structures.append(BuildableStructure.new(idx, ui))
	structure_panel_container.get_parent().add_child(ui)
	ui.mouse_entered.connect(_on_line_item_mouse_entered.bind(idx))
	ui.mouse_exited.connect(_on_line_item_mouse_entered.bind(idx))
	ui.pressed.connect(_on_build_option_selected.bind(idx))
	ui.show()

func _on_build_option_selected(idx):
	GlobalSignalBus.ui_button_pressed.emit()
	StructureManager.buildable_structure_selected.emit(idx)


func handle_gui_input(event: InputEvent, idx: int):
	if event is InputEventMouseMotion:
		var structure_name: String  = StructureManager.structure_data[idx][StructureManager.StructureFields.STRUCTURE_NAME]
		%HoverPanel.show_preview(idx)
		return
		
		var requirements_missing = StructureManager.check_structure_requirements(idx)
		if requirements_missing:
			var formatted_requirements_missing = ", ".join(requirements_missing)
			$VBoxContainer/HoverPanel/VBoxContainer/HBoxContainer/VBoxContainer/Label2.text = formatted_requirements_missing	
		else:
			$VBoxContainer/HoverPanel/VBoxContainer/HBoxContainer/VBoxContainer/Label2.text = ""
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		StructureManager.buildable_structure_selected.emit(idx)
		get_viewport().set_input_as_handled()
