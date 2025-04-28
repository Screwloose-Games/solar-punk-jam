extends CanvasLayer
class_name HUDCanvasLayer

class Singleton:
	static var instance: HUDCanvasLayer

@onready var buildable_structure_ui_template = $HUD/BottomCenterMarginContainer/ToolbarBackgroundPanelContainer/ToolbarMarginContainer/ToolbarHBoxContainer/ToolbarItemPanelContainer
@onready var resource_ui_template = $HUD/LeftMiddleMarginContainer/VBoxContainer/ResourceLabel
@export var unlock_all_structures_from_the_start_for_debugging = false
var buildable_structures: Array[BuildableStructure] = []
var resource_to_control = {}


func _ready() -> void:
	HUDCanvasLayer.Singleton.instance = self
	EnvironmentManager.day_cycle_update.connect(self.update_time_hud)
	if unlock_all_structures_from_the_start_for_debugging:
		for idx in len(StructureManager.structure_data):
			register_structure_as_hud_icon(idx)
	StructureManager.UpdatedAvailableStructures.connect(self.refresh_structure_build_palette)
	EnvironmentManager.UpdatedAvailableResources.connect(self.refresh_resources_ui)
	$HUD/PopupMenuMarginContainer/VBoxContainer/CenterContainer/HBoxContainer/Close.connect("pressed", close_popup_menu)


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
		var requirements_missing = StructureManager.check_structure_requirements(idx)
		if requirements_missing:
			set_tool_tip("Cannot build " + StructureManager.structure_data[idx][StructureManager.STRUCTURE_FIELDS.StructureName] + "\nMissing: " + requirements_missing[0], 
			get_viewport().get_mouse_position())
		else:
			set_tool_tip("Build " + StructureManager.structure_data[idx][StructureManager.STRUCTURE_FIELDS.StructureName], get_viewport().get_mouse_position())
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		StructureManager.BuildableStructureSelected.emit(idx)
		get_viewport().set_input_as_handled()

var tool_tip_tween: Tween
@onready var tooltip_label := $HUD/TooltipLabel as Label
func kill_tool_tip():
	if tool_tip_tween:
		tool_tip_tween.kill()
	tooltip_label.modulate = Color(1,1,1,0)
func set_tool_tip(text: String, position: Vector2):
	tooltip_label.size = Vector2.ZERO
	tooltip_label.text = text
	tooltip_label.position = position
	tooltip_label.position.y -= 4 + tooltip_label.size.y
	tooltip_label.position.x -= tooltip_label.size.x / 2
	tooltip_label.modulate = Color.WHITE
	if tool_tip_tween:
		tool_tip_tween.kill()
	tool_tip_tween = create_tween()
	tool_tip_tween.tween_property(tooltip_label, "modulate", Color(1,1,1,0), 0.3).set_delay(0.3)


#func show_popup_menu( title: String, text: String, status: String, gain_resource: String):
func show_popup_menu(structure: StructureManager.BuiltStructure):
	$HUD/PopupMenuMarginContainer/VBoxContainer/TitleLabel.text = StructureManager.structure_data[structure.structure][StructureManager.STRUCTURE_FIELDS.StructureName]
	$HUD/PopupMenuMarginContainer/VBoxContainer/DescriptionLabel.text = StructureManager.structure_data[structure.structure][StructureManager.STRUCTURE_FIELDS.StructureDescription]
	var collect_button := $HUD/PopupMenuMarginContainer/VBoxContainer/CenterContainer/HBoxContainer/Collect as Button
	if structure.ready_to_be_collected:
		$HUD/PopupMenuMarginContainer/VBoxContainer/StatusLabel.text = "Has "+str(len(structure.ready_to_be_collected))+" thing to be collected"
		collect_button.show()
		for i in collect_button.get_signal_connection_list("pressed"):
			collect_button.disconnect("pressed", i["callable"])
		collect_button.connect("pressed", structure.collect_today)
		#collect_button.connect("pressed", collect_button.hide)
	else:
		$HUD/PopupMenuMarginContainer/VBoxContainer/StatusLabel.text = "Nothing to collect"
		collect_button.hide()
	$HUD/PopupMenuMarginContainer.show()
	
func close_popup_menu():
	$HUD/PopupMenuMarginContainer.hide()
