extends CanvasLayer
class_name HUDCanvasLayer

signal BuildableStructureSelected(idx: int)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ToggleUi"):
		visible = !visible


class BuildableStructure:
	var idx: int
	var ui: Control
	func _init(idx, ui) -> void:
		self.idx = idx
		self.ui = ui

@onready var buildable_structure_ui_template = $HUD/BottomCenterMarginContainer/ToolbarBackgroundPanelContainer/ToolbarMarginContainer/ToolbarHBoxContainer/ToolbarItemPanelContainer
var buildable_structures: Array[BuildableStructure] = []

# TODO make world_data available as singleton or autoload
var cached_world_data = []
		
func register_structure(idx):
	var ui = buildable_structure_ui_template.duplicate()
	buildable_structures.append(BuildableStructure.new(idx, ui))
	buildable_structure_ui_template.get_parent().add_child(ui)
	
	var icon = ui.get_node("TextureRect") as TextureRect
	icon.connect("gui_input", handle_gui_input.bind(idx))
	icon.texture = icon.texture.duplicate()
	var atlas = icon.texture as AtlasTexture
	var icon_atlas_coords = cached_world_data[idx][7].split("/")
	atlas.region = Rect2(80*int(icon_atlas_coords[0]),80*int(icon_atlas_coords[1]),80,80)
	var label = ui.get_node("Control/MarginContainer/Label") as Label
	label.text = str(len(buildable_structures))
	ui.show()
	

func handle_gui_input(event: InputEvent, idx: int):
	if event is InputEventMouseMotion:
		$HUD/TooltipLabel.text = cached_world_data[idx][0]
		$HUD/TooltipLabel.position = get_viewport().get_mouse_position()
		
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		BuildableStructureSelected.emit(idx)
	
