class_name QuestMarker3D
extends Marker3D

@export var marker_id: String
@export var active: bool = false:
	set(val):
		active = val
		visible = active
		
@export var distance: int = 100

func _ready() -> void:
	visible = false

func _process(delta: float) -> void:
	pass
	# make the number disappear if within 10m of range. 



# configure marker ID
# Add marker_if to quest objective
# 
# 
# 
# 
