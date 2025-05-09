class_name DailySummaryUi
extends CanvasLayer

signal closed

@export var fade_in_time: float = 1.0
@export var fade_out_time: float = 1.0

@onready var dashboard_close_button: Button = %DashboardCloseButton
@onready var daily_summary_center_container: CenterContainer = %DailySummaryCenterContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visibility_changed.connect(_on_visibility_changed)
	dashboard_close_button.pressed.connect(_on_close_pressed)
	hide()

func _on_close_pressed():
	closed.emit()
	close()

func _on_visibility_changed():
	if visible:
		process_mode = Node.PROCESS_MODE_ALWAYS
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_day_cycle_end():
	show_daily_summary()

func show_daily_summary():
	print("day cycle ended")
	daily_summary_center_container.modulate = Color.TRANSPARENT
	show()
	
	var summary = ""
	for resource in EnvironmentManager.daily_resources:
		summary += resource + ": " + str(EnvironmentManager.daily_resources[resource])
		%Summary.text = summary
	EnvironmentManager.daily_resources = {}
	var tween: Tween = create_tween()
	tween.tween_property(daily_summary_center_container, "modulate", Color.WHITE, fade_in_time)

func close():
	var tween: Tween = create_tween()
	tween.tween_property(daily_summary_center_container, "modulate", Color.TRANSPARENT, fade_out_time)
	await tween.finished
	hide()
