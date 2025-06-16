extends Area3D

@export var id: String = "area_id"


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		print("Player entered quest trigger: %s" % id)
		GlobalSignalBus.quest_trigger_area_entered.emit(id)
