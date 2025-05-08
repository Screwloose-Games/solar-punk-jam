class_name QuestMarker3D
extends Marker3D

@export var marker_id: String
@export var active: bool = false:
	set(val):
		active = val
		visible = active

func _ready() -> void:
	visible = false
