extends Node3D

@onready var hud := $HUDCanvasLayer as HUDCanvasLayer


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_WHEEL_UP:
		$Camera3D.fov *= 1.1
	elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_WHEEL_DOWN:
		$Camera3D.fov *= 0.9
	elif event is InputEventKey and event.pressed and event.keycode == KEY_1:
		$BuildableSurface1.is_active = true
		$BuildableSurface2.is_active = false
		$BuildableSurface3.is_active = false
	elif event is InputEventKey and event.pressed and event.keycode == KEY_2:
		$BuildableSurface1.is_active = false
		$BuildableSurface2.is_active = true
		$BuildableSurface3.is_active = false
	elif event is InputEventKey and event.pressed and event.keycode == KEY_3:
		$BuildableSurface1.is_active = false
		$BuildableSurface2.is_active = false
		$BuildableSurface3.is_active = true
