extends CanvasLayer

@export var player_initialted: bool = false
@export var events: Array[String] = []
@export var show_mom_info_time: float = 3.0
@export var fade_time: float = 2.0


@onready var momtake_te_home_canvas_layer: MomTakeTeHomeCanvasLayer = %MomtakeTeHomeCanvasLayer
@onready var daily_dashboard: DailySummaryUi = %DailyDashboard
@onready var black: ColorRect = %Black

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	EnvironmentManager.day_cycle_end.connect(_on_day_cycle_end)
	EnvironmentManager.force_end_day.connect(_on_force_end_day)
	black.hide()

func _on_force_end_day():
	player_initialted = true


func show_forced_screen():
	momtake_te_home_canvas_layer.show()
	await get_tree().create_timer(show_mom_info_time).timeout
	momtake_te_home_canvas_layer.hide()

func show_dashboard():
	daily_dashboard.show_daily_summary()
	await daily_dashboard.closed

func _on_day_cycle_end():
	start_sequence()

func start_sequence():
	#on event went to night.
	get_tree().paused = true
	await fade_to_black()
	if not player_initialted:
		await show_forced_screen()
	show_dashboard()
	await fade_from_black()
	get_tree().paused = false

func fade_to_black():
	black.color = Color.TRANSPARENT
	black.show()
	var tween = create_tween()
	tween.tween_property(black, "modulate", Color.BLACK, fade_time)
	await tween.finished

func fade_from_black():
	black.color = Color.BLACK
	var tween = create_tween()
	tween.tween_property(black, "modulate", Color.TRANSPARENT, fade_time)
	await tween.finished
	black.hide()
