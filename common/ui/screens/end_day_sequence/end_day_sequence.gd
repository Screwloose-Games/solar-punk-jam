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
	black.show()
	black.color = Color.BLACK
	black.color = Color.BLACK
	EnvironmentManager.environment_model
	var environment: CapybaraEnvironment = get_tree().get_first_node_in_group("DynamicEnvironment")
	#await get_tree().create_timer(2).timeout # we need to wait because environment will skip an extra day if we dont.
	get_tree().paused = true
	
	if not player_initialted:
		await show_forced_screen()
	await show_dashboard()
	await fade_from_black()
	environment.animate_day()
	get_tree().paused = false
	player_initialted = false

func fade_to_black():
	black.color = Color.TRANSPARENT
	black.show()
	var tween = create_tween()
	tween.tween_property(black, "color", Color.BLACK, fade_time)
	await tween.finished

func fade_from_black():
	black.color = Color.BLACK
	var tween = create_tween()
	tween.tween_property(black, "color", Color.TRANSPARENT, fade_time)
	await tween.finished
	black.hide()
