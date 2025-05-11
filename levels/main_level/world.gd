extends Node3D

func _enter_tree() -> void:
	GlobalSignalBus.world_loaded.emit()

func _exit_tree() -> void:
	GlobalSignalBus.world_unloaded.emit()
