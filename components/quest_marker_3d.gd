class_name QuestMarker3D
extends Marker3D

@export_enum("trin", "kai", "home_entrance", "mister", "material_location", 
"board", "water", "trin_garden", "home_roof_garden", "go_to_bed_door",
"trin_compost", "trin_water", "community_food_stand", "vertical_garden") var id: String
@export var active: bool = false:
	set(val):
		active = val
		visible = active
		if not is_node_ready():
			await ready
		if active:
			player = get_tree().get_first_node_in_group("Player")

@export var hide_within_distance_meters: float = 10.0

var player: Player

var is_within_hide_distance: bool:
	get:
		return distance_to_player_meters < hide_within_distance_meters

var distance_to_player_meters: float

@onready var distance_label_3d: Label3D = %DistanceLabel3D

func _ready() -> void:
	visible = false

func _process(delta: float) -> void:
	if active:
		distance_to_player_meters = player.global_position.distance_to(global_position)
		distance_label_3d.visible = !is_within_hide_distance
		distance_label_3d.text = str(int(distance_to_player_meters)) + "m"
