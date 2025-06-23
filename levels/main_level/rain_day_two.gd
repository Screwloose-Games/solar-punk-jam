extends Node

@onready var environment: CapybaraEnvironment = %Environment

func _ready() -> void:
	EnvironmentManager.environment_model.day_updated.connect(_on_day_updated)
	GlobalSignalBus.daily_summary_continue_clicked.connect(_on_daily_dashboard_closed)

func _on_daily_dashboard_closed():
	#Dialogic.start(DIALOGIC_TIMELINE)
	GlobalSignalBus.daily_summary_continue_clicked.disconnect(_on_daily_dashboard_closed)

func _on_day_updated(day_num: int):
	if day_num == 2:
		await get_tree().process_frame
		environment.is_raining = true
