extends Node3D


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if !event.pressed:
			match event.keycode:
				KEY_1:
					GlobalSignalBus.structure_built.emit("build1")
				KEY_2:
					GlobalSignalBus.structure_built.emit("build2")
				KEY_3:
					GlobalSignalBus.structure_built.emit("build3")
