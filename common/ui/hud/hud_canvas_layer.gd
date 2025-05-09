extends CanvasLayer
class_name HUDCanvasLayer

class Singleton:
	static var instance: HUDCanvasLayer

#@onready var buildable_structure_ui_template = $HUD/BottomCenterMarginContainer/ToolbarBackgroundPanelContainer/ToolbarMarginContainer/ToolbarHBoxContainer/ToolbarItemPanelContainer
@onready var buildable_structure_ui_template_enabled = $VBoxContainer/PanelContainer/ScrollContainer/VBoxContainer/PanelContainerEnabled
@onready var buildable_structure_ui_template_disabled = $VBoxContainer/PanelContainer/ScrollContainer/VBoxContainer/PanelContainerDisabled
@onready var resource_ui_template = $HUD/LeftMiddleMarginContainer/VBoxContainer/ResourceLabel
@export var unlock_all_structures_from_the_start_for_debugging = false
@onready var act_number_label: Label = %ActNumberLabel
var buildable_structures: Array[BuildableStructure] = []
var resource_to_control = {}
@export var weather_icon_sunny: Texture
@export var weather_icon_rainy: Texture
## How long to show resources on screen when the number changes collect / spend.
@export var resource_show_time: float = 1.5


@onready var bottom_center_margin_container: Control = %BottomCenterMarginContainer
@onready var left_middle_margin_container: MarginContainer = %LeftMiddleMarginContainer


func _ready() -> void:
	EnvironmentManager.act_updated.connect(_on_act_updated)
	HUDCanvasLayer.Singleton.instance = self
	EnvironmentManager.day_cycle_update.connect(self.update_time_hud)
	if unlock_all_structures_from_the_start_for_debugging:
		for idx in len(StructureManager.structure_data):
			register_structure_as_hud_icon(idx)
	StructureManager.UpdatedAvailableStructures.connect(self.refresh_structure_build_palette)
	EnvironmentManager.UpdatedAvailableResources.connect(self.refresh_resources_ui)
	$HUD/PopupMenuMarginContainer/VBoxContainer/CenterContainer/HBoxContainer/Close.connect("pressed", close_popup_menu)
	%HoverPanel.hide()
	buildable_structure_ui_template_enabled.hide()
	buildable_structure_ui_template_disabled.hide()
	# Ensure we update UI on startup
	refresh_resources_ui.call_deferred()

func _on_act_updated(act_num: int):
	act_number_label.text = str(act_num)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ToggleUi"):
		visible = !visible

func show_build_tray():
	bottom_center_margin_container.show_with_slide()

func hide_build_tray():
	bottom_center_margin_container.hide_with_slide()

func update_time_hud(_offset):
	%WeatherIcon.texture = weather_icon_rainy if EnvironmentManager.environment_model.is_raining else weather_icon_sunny
	var time := EnvironmentManager.environment_model.get_in_game_time()
	%Day.text = str(time.day)
	%Time.text = "%d:%02d" % [time.hour, time.minute]
	%AmPm.text = "PM" if time.is_pm else "AM"

func refresh_resources_ui():
	$HUD/LeftMiddleMarginContainer.show()
	var in_tween: Tween = fade_in_left_middle_container()
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
	%CommunityProgressBar.value = EnvironmentManager.current_resources.get("Happiness", 0)
	%EnvironmentProgressBar.value = EnvironmentManager.current_resources.get("Environment", 0)
	%CommunityStatusLabel.text = str(EnvironmentManager.current_resources.get("Happiness", 0))
	%EnvironmentStatusLabel.text = str(EnvironmentManager.current_resources.get("Environment", 0))
	
	await in_tween.finished
	await get_tree().create_timer(resource_show_time).timeout
	fade_out_left_middle_container()

func fade_in_left_middle_container() -> Tween:
	var tween = create_tween()
	tween.tween_property(left_middle_margin_container, "modulate:a", 1.0, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	return tween

func fade_out_left_middle_container() -> Tween:
	var tween = create_tween()
	tween.tween_property(left_middle_margin_container, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	return tween

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
	
	var requirements_missing = StructureManager.check_structure_requirements(idx)
	var ui = null
	if requirements_missing:
		ui = buildable_structure_ui_template_disabled.duplicate()
	else:
		ui = buildable_structure_ui_template_enabled.duplicate()

	buildable_structures.append(BuildableStructure.new(idx, ui))
	buildable_structure_ui_template_enabled.get_parent().add_child(ui)
	var icon = ui.get_node("HBoxContainer/Icon") as TextureRect
	icon.connect("gui_input", handle_gui_input.bind(idx))
	icon.texture = preload("res://assets/2d/ui/icon-compost-bin-25px.png")
	var file_name = StructureManager.structure_data[idx][StructureManager.STRUCTURE_FIELDS.StructureModel]
	var icon_name = file_name.rsplit(".", true, 1)[0]
	icon_name = "icon-" + icon_name.replace("_", "-") + "-25px.png"
	var icon_data = load("res://assets/2d/ui/" + icon_name)
	if icon_data:
		icon.texture = icon_data
	var label = ui.get_node("HBoxContainer/Label") as Label
	label.text = StructureManager.structure_data[idx][StructureManager.STRUCTURE_FIELDS.StructureName]
	label.connect("gui_input", handle_gui_input.bind(idx))
	label.connect("mouse_entered", %HoverPanel.show)
	label.connect("mouse_exited", %HoverPanel.hide)
	ui.show()


func handle_gui_input(event: InputEvent, idx: int):
	if event is InputEventMouseMotion:
		%HoverPanel.show()
		$VBoxContainer/HoverPanel/VBoxContainer/HBoxContainer2/Title.text = StructureManager.structure_data[idx][StructureManager.STRUCTURE_FIELDS.StructureName]
		$VBoxContainer/HoverPanel/VBoxContainer/HBoxContainer/VBoxContainer/Label.text = StructureManager.structure_data[idx][StructureManager.STRUCTURE_FIELDS.StructureDescription]
		var icon = $VBoxContainer/HoverPanel/VBoxContainer/HBoxContainer/Icon
		var file_name = StructureManager.structure_data[idx][StructureManager.STRUCTURE_FIELDS.StructureModel]
		var icon_name = file_name.rsplit(".", true, 1)[0]
		icon_name = "icon-" + icon_name.replace("_", "-") + "-118px.png"
		var icon_data = load("res://assets/2d/ui/" + icon_name)
		if icon_data:
			icon.texture = icon_data

		
		var requirements_missing = StructureManager.check_structure_requirements(idx)
		if requirements_missing:
			var formatted_requirements_missing = ", ".join(requirements_missing)
			$VBoxContainer/HoverPanel/VBoxContainer/HBoxContainer/VBoxContainer/Label2.text = formatted_requirements_missing	
		else:
			$VBoxContainer/HoverPanel/VBoxContainer/HBoxContainer/VBoxContainer/Label2.text = ""
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
