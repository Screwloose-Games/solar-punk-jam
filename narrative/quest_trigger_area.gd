extends Area3D

@export var id : String = "area_id"


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		GlobalSignalBus.quest_trigger_area_entered.emit(id)
