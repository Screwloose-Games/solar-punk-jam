extends Node

@export var crop: Crop
## Where the visual instance of a crop should be located.

@onready var structure_interact_canvas_layer: CanvasLayer = %StructureInteractCanvasLayer
@onready var planting_ui_margin_container: PlantingUI = %PlantingUiMarginContainer
@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D
@onready var visual_instance_target: Marker3D = %VisualInstanceMarker3D
@onready var visual_instance_marker_3d: Marker3D = %VisualInstanceMarker3D

var current_crop_visual_instances: Array[Node3D] = []
var markers: Array[Node]

func _ready() -> void:
	markers = visual_instance_marker_3d.get_children()
	planting_ui_margin_container.seed_planted.connect(_on_seed_planted)
	interactable_area_3d.interacted.connect(_on_interacted)
	planting_ui_margin_container.closed.connect(hide_ui)
	structure_interact_canvas_layer.hide()
	EnvironmentManager.day_cycle_end.connect(_on_day_cycle_end)

func _on_day_cycle_end():
	await get_tree().create_timer(0.2).timeout # wait till the player goes to bed
	mature_crops()

func show_ui():
	GlobalSignalBus.seed_ui_shown.emit()
	structure_interact_canvas_layer.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hide_ui():
	structure_interact_canvas_layer.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	interactable_area_3d.stop_interacting()

func _on_interacted(player: Player):
	if not crop:
		show_ui()
	elif crop.is_harvestable():
		harvest_crop()
	else:
		interactable_area_3d.stop_interacting()
		#todo: Crop not harvestable yet


func mature_crops():
	if not crop:
		return
	crop.mature_crop()
	if crop.is_harvestable():
		clear_visuals()
		add_crop_visuals(crop.mature_scene)

func clear_visuals():
	for marker in markers:
		for child in marker.get_children():
			child.queue_free()

func add_crop_visuals(visual_instance_scene: PackedScene):
	for marker in markers:
		var visual_instance = visual_instance_scene.instantiate()
		marker.add_child(visual_instance)

func _on_day_passed():
	mature_crops()

func harvest_crop():
	ResourcesManager.gain_resource("Food", crop.harvest_amount)
	GlobalSignalBus.crop_harvested.emit(crop.type)
	crop = null
	clear_visuals()
	interactable_area_3d.stop_interacting()

func _on_seed_planted(crop: Crop):
	plant_crop(crop)

func plant_crop(new_crop: Crop):
	# pay cost
	ResourcesManager.spend_resources(Crop.planting_requirements)
	crop = new_crop
	add_crop_visuals(crop.planted_scene)
	GlobalSignalBus.seed_planted.emit(new_crop)
	hide_ui()
