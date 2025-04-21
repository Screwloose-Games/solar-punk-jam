extends Node3D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_RIGHT and event.pressed:
		$DayCycle.is_raining = !$DayCycle.is_raining
		$Rain.visible = $DayCycle.is_raining
		$Rain/CanvasLayer.visible = $DayCycle.is_raining
	elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:
		var structure := $Structure.duplicate() as MeshInstance3D
		add_child(structure)
		structure.position = $SelectionPlaceholder.position
		structure.mesh = structure.mesh.duplicate()
		var x := structure.mesh
		x.material = x.material.duplicate()
		x.material.albedo_color.b = randf() * 0.5
	elif event is InputEventMouseMotion:
		var position_screen = get_viewport().get_mouse_position()
		var plane := Plane.PLANE_XZ
		plane.d = -1.0
		var camera := $Player/Camera3D as Camera3D
		var intersect : Variant = plane.intersects_ray(
			camera.project_ray_origin(position_screen),
			camera.project_ray_normal(position_screen)
		)
		if intersect:
			intersect.x = round(intersect.x)
			intersect.y = round(intersect.y)
			intersect.z = round(intersect.z)
			$SelectionPlaceholder.position = intersect
