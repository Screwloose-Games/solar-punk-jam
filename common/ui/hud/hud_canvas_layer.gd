extends CanvasLayer
class_name HUDCanvasLayer

@onready var buildable_structure_ui_template = $HUD/BottomCenterMarginContainer/ToolbarBackgroundPanelContainer/ToolbarMarginContainer/ToolbarHBoxContainer/ToolbarItemPanelContainer
@onready var resource_ui_template = $HUD/LeftMiddleMarginContainer/VBoxContainer/ResourceLabel
@export var unlock_all_structures_from_the_start_for_debugging = false
var buildable_structures: Array[BuildableStructure] = []
var resource_to_control = {}


func _ready() -> void:
	EnvironmentManager.day_cycle_update.connect(self.update_time_hud)
	if unlock_all_structures_from_the_start_for_debugging:
		for idx in len(StructureManager.structure_data):
			register_structure_as_hud_icon(idx)
	StructureManager.UpdatedAvailableStructures.connect(self.refresh_structure_build_palette)
	EnvironmentManager.UpdatedAvailableResources.connect(self.refresh_resources_ui)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ToggleUi"):
		visible = !visible


func update_time_hud(_offset):
	var time := EnvironmentManager.environment_model.get_in_game_time()
	$HUD/TopRightMarginContainer/WeatherTimeHBoxContainer/PanelContainer/MarginContainer/VBoxContainer/DateHBoxContainer/Day.text = str(time.day)
	$HUD/TopRightMarginContainer/WeatherTimeHBoxContainer/PanelContainer/MarginContainer/VBoxContainer/TimeHBoxContainer/Time.text = "%d:%02d" % [time.hour, time.minute]
	$HUD/TopRightMarginContainer/WeatherTimeHBoxContainer/PanelContainer/MarginContainer/VBoxContainer/TimeHBoxContainer/AmPm.text = "PM" if time.is_pm else "AM"

func refresh_resources_ui():
	$HUD/LeftMiddleMarginContainer.show()
	for i in EnvironmentManager.current_resources:
		var q = EnvironmentManager.current_resources[i]
		var t = i + ": " + str(q)
		if i in resource_to_control:
			resource_to_control[i].text = t
		else:
			var ui := resource_ui_template.duplicate() as Label
			resource_to_control[i]=ui
			resource_ui_template.get_parent().add_child(ui)
			ui.text = t
			ui.show()

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

func register_structure_as_hud_icon(idx):
	var ui = buildable_structure_ui_template.duplicate()
	buildable_structures.append(BuildableStructure.new(idx, ui))
	buildable_structure_ui_template.get_parent().add_child(ui)
	var icon = ui.get_node("TextureRect") as TextureRect
	icon.connect("gui_input", handle_gui_input.bind(idx))
	icon.texture = icon.texture.duplicate()
	var atlas = icon.texture as AtlasTexture
	var icon_atlas_coords = StructureManager.structure_data[idx][StructureManager.STRUCTURE_FIELDS.StructureIcon].split(",")
	atlas.region = Rect2(80*int(icon_atlas_coords[0]),80*int(icon_atlas_coords[1]),80,80)
	var label = ui.get_node("Control/MarginContainer/Label") as Label
	label.text = str(len(buildable_structures))
	ui.show()


func handle_gui_input(event: InputEvent, idx: int):
	if event is InputEventMouseMotion:
		$HUD/TooltipLabel.text = StructureManager.structure_data[idx][0]
		$HUD/TooltipLabel.position = get_viewport().get_mouse_position()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		StructureManager.BuildableStructureSelected.emit(idx)
