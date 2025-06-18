class_name HUDCanvasLayer
extends CanvasLayer

@export var unlock_all_structures_from_the_start_for_debugging = false
@export var weather_icon_sunny: Texture
@export var weather_icon_rainy: Texture
## How long to show resources on screen when the number changes collect / spend.
@export var resource_show_time: float = 1.5
var tool_tip_tween: Tween
var resource_to_control = {}

@onready var structure_panel_container = %StructurePanelContainer
@onready var resource_ui_template = %ResourceLabel
@onready var act_number_label: Label = %ActNumberLabel
@onready var bottom_center_margin_container: Control = %BottomCenterMarginContainer
@onready var left_middle_margin_container: MarginContainer = %LeftMiddleMarginContainer
@onready var build_ui_container: BuildUiContainer = %BuildUIContainer
@onready var hud_container: Control = $HUD  # Your root Control inside the CanvasLayer
@onready var tooltip_label := $HUD/TooltipLabel as Label


func _ready() -> void:
	get_viewport().size_changed.connect(_on_screen_resized)
	build_ui_container.unlock_all_structures_from_the_start_for_debugging = unlock_all_structures_from_the_start_for_debugging
	EnvironmentManager.act_updated.connect(_on_act_updated)
	HUDCanvasLayer.Singleton.instance = self
	EnvironmentManager.day_cycle_update.connect(self.update_time_hud)
	ResourcesManager.updated_available_resources.connect(self.refresh_resources_ui)
	# Ensure we update UI on startup
	refresh_resources_ui.call_deferred()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ToggleUi"):
		visible = !visible


func _on_screen_resized():
	hud_container.size = get_viewport().size


func _on_act_updated(act_num: int):
	act_number_label.text = str(act_num)


func update_time_hud(_offset):
	%WeatherIcon.texture = weather_icon_rainy if EnvironmentManager.environment_model.is_raining else weather_icon_sunny
	var time := EnvironmentManager.environment_model.get_in_game_time()
	%Day.text = str(time.day)
	%Time.text = "%d:%02d" % [time.hour, time.minute]
	%AmPm.text = "PM" if time.is_pm else "AM"


func refresh_resources_ui():
	$HUD/LeftMiddleMarginContainer.show()
	var in_tween: Tween = fade_in_left_middle_container()
	# Hide all existing resource labels first
	for control in resource_to_control.values():
		control.hide()
	# Show only resources with non-zero counts
	for i in ResourcesManager.current_resources:
		var q = ResourcesManager.current_resources[i]
		# Skip resources with zero count
		if q == 0:
			continue
		var t = i + ": " + str(q)
		if i in resource_to_control:
			resource_to_control[i].text = t
			resource_to_control[i].show()
		else:
			var ui := resource_ui_template.duplicate() as Label
			resource_to_control[i] = ui
			resource_ui_template.get_parent().add_child(ui)
			ui.text = t
			ui.show()
	%CommunityProgressBar.value = ResourcesManager.get_resource_count(ResourcesManager.ResourceType.HAPPINESS)
	%EnvironmentProgressBar.value = ResourcesManager.get_resource_count(ResourcesManager.ResourceType.ENVIRONMENT)
	%CommunityStatusLabel.text = str(ResourcesManager.get_resource_count(ResourcesManager.ResourceType.HAPPINESS))
	%EnvironmentStatusLabel.text = str(ResourcesManager.get_resource_count(ResourcesManager.ResourceType.ENVIRONMENT))
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


func close_popup_menu():
	$HUD/PopupMenuMarginContainer.hide()


class Singleton:
	static var instance: HUDCanvasLayer
