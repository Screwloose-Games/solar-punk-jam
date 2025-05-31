extends Node3D

func _exit_tree() -> void:
	GlobalSignalBus.world_unloaded.emit()
