extends Node

@export var crop: Crop
## Where the visual instance of a crop should be located.
@onready var visual_instance_marker_3d: Marker3D 

@onready var structure_interact_canvas_layer: CanvasLayer = %StructureInteractCanvasLayer
@onready var planting_ui_margin_container: PlantingUI = %PlantingUiMarginContainer
@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D
@onready var visual_instance_target: Marker3D = %VisualInstanceMarker3D

var current_crop_visual_instance: Node3D

func _ready() -> void:
	planting_ui_margin_container.seed_planted.connect(_on_seed_planted)
	interactable_area_3d.interacted.connect(_on_interacted)
	planting_ui_margin_container.closed.connect(hide_ui)
	structure_interact_canvas_layer.hide()
	EnvironmentManager.day_cycle_end.connect(_on_day_cycle_end)

func _on_day_cycle_end():
	await get_tree().create_timer(0.2).timeout # wait till the player goes to bed
	mature_crops()

func show_ui():
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
		var mature_visual_instance = crop.mature_scene.instantiate()
		visual_instance_target.add_child(mature_visual_instance)
		current_crop_visual_instance.queue_free()
		current_crop_visual_instance = mature_visual_instance

func _on_day_passed():
	mature_crops()

func harvest_crop():
	EnvironmentManager.gain_resource("Food", crop.harvest_amount)
	crop = null
	current_crop_visual_instance.queue_free()
	current_crop_visual_instance = null
	interactable_area_3d.stop_interacting()

func _on_seed_planted(crop: Crop):
	plant_crop(crop)

func plant_crop(new_crop: Crop):
	# pay cost
	EnvironmentManager.spend_resources(Crop.planting_requirements)
	crop = new_crop
	var crop_visual_instance: Node3D = crop.planted_scene.instantiate()
	visual_instance_target.add_child(crop_visual_instance)
	current_crop_visual_instance = crop_visual_instance
	hide_ui()
