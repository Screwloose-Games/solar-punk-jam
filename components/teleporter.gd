class_name Teleporter
extends Area3D

signal interacted

@export var destination_mark: Teleporter
@export var debounce_time: float = 0.5

var area_active: bool = false


func debounce():
	destination_mark.monitoring = false
	await get_tree().create_timer(debounce_time).timeout
	destination_mark.monitoring = true


func _ready():
	area_entered.connect(_on_area_entered)


func teleport(player: Player):
	debounce()
	player.global_position = destination_mark.global_position


func _on_area_entered(area: Area3D) -> void:
	var area_owner = area.owner
	if area_owner is Player:
		teleport(area_owner)
