class_name DailySummaryUi
extends CanvasLayer

const DAILY_DASHBOARD_ROW_ITEM = preload("res://common/ui/screens/daily_dashboard/daily_dashboard_row_item.tscn")

signal closed

@export var fade_in_time: float = 1.0
@export var fade_out_time: float = 1.0

@onready var dashboard_close_button: Button = %DashboardCloseButton
@onready var daily_summary_center_container: CenterContainer = %DailySummaryCenterContainer
@onready var reward_list: VBoxContainer = %RewardList
@onready var summary_label: Label = %SummaryLabel
@onready var happiness: DailySummaryItemUi = %Happiness
@onready var environment: DailySummaryItemUi = %Environment

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visibility_changed.connect(_on_visibility_changed)
	dashboard_close_button.pressed.connect(_on_close_pressed)
	hide()

func _on_close_pressed():
	closed.emit()
	GlobalSignalBus.daily_summary_continue_clicked.emit()
	close()

func _on_visibility_changed():
	if visible:
		process_mode = Node.PROCESS_MODE_ALWAYS
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_day_cycle_end():
	show_daily_summary()


func show_environment():
	if "Environment" in ResourcesManager.daily_resources:
		environment.count = ResourcesManager.daily_resources["Environment"]

func show_happiness():
	if "Happiness" in ResourcesManager.daily_resources:
		happiness.count = ResourcesManager.daily_resources["Happiness"]


func show_daily_summary():
	var player: Player = get_tree().get_first_node_in_group("Player")
	player.force_ignore_input = true
	daily_summary_center_container.modulate = Color.TRANSPARENT
	show()
	show_environment()
	show_happiness()
	#show_resources()

	ResourcesManager.daily_resources = {}
	var tween: Tween = create_tween()
	tween.tween_property(daily_summary_center_container, "modulate", Color.WHITE, fade_in_time)

func show_resources():
	for child in reward_list.get_children():
		child.queue_free()

	for resource in ResourcesManager.daily_resources:
		if resource == "Happiness" or resource == "Happiness":
			continue
		var row_item: DailySummaryItemUi = DAILY_DASHBOARD_ROW_ITEM.instantiate()
		row_item.count = ResourcesManager.daily_resources[resource]
		row_item.item_name = resource
		reward_list.add_child(row_item)

func close():
	var tween: Tween = create_tween()
	tween.tween_property(daily_summary_center_container, "modulate", Color.TRANSPARENT, fade_out_time)
	await tween.finished
	var player: Player = get_tree().get_first_node_in_group("Player")
	player.force_ignore_input = false
	hide()
