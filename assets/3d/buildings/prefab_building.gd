extends Node3D

@export var destination_surface_path: NodePath

func _ready() -> void:
	var doorway = get_node_or_null("DoorwayBottom")
	if doorway:
		doorway.destination_surface = get_node_or_null(destination_surface_path)
