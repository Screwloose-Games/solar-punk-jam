extends CanvasLayer
class_name HUDCanvasLayer

const QUEST_CONTAINER_RES = preload("res://common/ui/components/quest/quest_container.tscn")

class BuildableStructure:
	var idx: int
	var ui: Control
	func _init(idx, ui) -> void:
		self.idx = idx
		self.ui = ui

@onready var quest_list = $HUD/TopLeftMarginContainer/VBoxContainer/Quests/List
@onready var buildable_structure_ui_template = $HUD/BottomCenterMarginContainer/ToolbarBackgroundPanelContainer/ToolbarMarginContainer/ToolbarHBoxContainer/ToolbarItemPanelContainer

# TODO make world_data available as singleton or autoload
var cached_world_data = []
var buildable_structures: Array[BuildableStructure] = []


func _ready() -> void:
	QuestManager.quests_changed.connect(update_quests)
	EnvironmentManager.connect("day_cycle_update", self.update_time_hud)
	for idx in len(StructureManager.structure_data):
		register_structure_as_hud_icon(idx)	

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ToggleUi"):
		visible = !visible
	

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ToggleUi"):
		visible = !visible


func update_quests():
	var current_quests = quest_list.get_children()
	for i in QuestManager.quests.size():
		if i >= current_quests.size():
			var new_cont = QUEST_CONTAINER_RES.instantiate()
			quest_list.add_child(new_cont)
			new_cont.quest = QuestManager.quests[i]
		elif current_quests[i].quest == QuestManager.quests[i]:
			current_quests[i].update()


func update_time_hud(_offset):
	var time := EnvironmentManager.environment_model.get_in_game_time()
	$HUD/TopRightMarginContainer/WeatherTimeHBoxContainer/PanelContainer/MarginContainer/VBoxContainer/DateHBoxContainer/Day.text = str(time.day)
	$HUD/TopRightMarginContainer/WeatherTimeHBoxContainer/PanelContainer/MarginContainer/VBoxContainer/TimeHBoxContainer/Time.text = str(time.hour) + ":" + str(time.minute)
	$HUD/TopRightMarginContainer/WeatherTimeHBoxContainer/PanelContainer/MarginContainer/VBoxContainer/TimeHBoxContainer/AmPm.text = "PM" if time.is_pm else "AM"


func register_structure(idx):
	var ui = buildable_structure_ui_template.duplicate()
	buildable_structures.append(BuildableStructure.new(idx, ui))
	buildable_structure_ui_template.get_parent().add_child(ui)
	var icon = ui.get_node("TextureRect") as TextureRect
	icon.connect("gui_input", handle_gui_input.bind(idx))
	icon.texture = icon.texture.duplicate()
	var atlas = icon.texture as AtlasTexture
	var icon_atlas_coords = StructureManager.structure_data[idx][7].split("/")
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
	
