class_name DailySummaryUi
extends CanvasLayer

signal closed

@onready var dashboard_close_button: Button = %DashboardCloseButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visibility_changed.connect(_on_visibility_changed)
	dashboard_close_button.pressed.connect(_on_close_pressed)
	#EnvironmentManager.day_cycle_end.connect(_on_day_cycle_end)
	hide()

#func _process(delta: float) -> void:
	#return
	#if visible:
		#process_mode = Node.PROCESS_MODE_ALWAYS
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#

func _on_close_pressed():
	closed.emit()
	hide()

func _on_visibility_changed():
	if visible:
		process_mode = Node.PROCESS_MODE_ALWAYS
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		#process_mode = Node.PROCESS_MODE_INHERIT
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_day_cycle_end():
	show_daily_summary()

func show_daily_summary():
	print("day cycle ended")
	show()
	var summary = ""
	for resource in EnvironmentManager.daily_resources:
		summary += resource + ": " + str(EnvironmentManager.daily_resources[resource])
		%Summary.text = summary
	EnvironmentManager.daily_resources = {}
