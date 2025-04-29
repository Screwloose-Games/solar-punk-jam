class_name DemoSceneMenu
extends Control

@export var scenes: Array[PackedScene]

@onready var grid_container: GridContainer = %GridContainer

func _ready() -> void:
	for scene in scenes:
		create_scene_node(scene)

func load_scene(scene: PackedScene) -> void:
	get_tree().change_scene_to_packed(scene)

func create_scene_node(scene: PackedScene) -> void:
	var button := Button.new()
	
	button.text = scene.get_state().get_node_name(0)
	
	button.pressed.connect(load_scene.bind(scene))
	grid_container.add_child(button)
