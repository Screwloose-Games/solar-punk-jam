extends Node3D

@onready var selection_placeholder := $SelectionPlaceholder as Node3D
@onready var structure_placeholder := $StructurePlaceholder as Node3D
@onready var surface_map := $SurfaceMap as TileMap

@export var is_active := false:
	set(value):
		is_active = value
		if is_active:
			enable_cursor_3d()
		else:
			if selection_placeholder:
				selection_placeholder.hide()
				structure_placeholder.hide()

var building_rect := Rect2i()
var building_idx := -1
var can_build = false
var can_walk = false

func _ready() -> void:
	StructureManager.BuildableStructureSelected.connect(ready_structure_building)
	selection_placeholder.hide()
	structure_placeholder.hide()


func _input(event: InputEvent) -> void:
	if not is_active:
		return
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:
		if can_build:
			build_structure()
	elif event is InputEventMouseMotion:
		move_cursor_3d()

func ready_structure_building(idx):
	if not is_active:
		return
	structure_placeholder.show()
	building_rect = Rect2i(0,0,StructureManager.structure_data[idx][3],StructureManager.structure_data[idx][4])
	structure_placeholder.scale = Vector3(building_rect.size.x, 1, building_rect.size.y)
	can_build = false
	building_idx = idx
	
func enable_cursor_3d():
	move_cursor_3d()
	#var coords = surface_map.get_used_cells(0)[0]
	#coords += Vector2i(1,1)
	#selection_placeholder.position = Vector2()
	#selection_placeholder.show()

func move_cursor_3d():
	if not is_active or not get_viewport():
		return
	var position_screen = get_viewport().get_mouse_position()
	var plane := Plane.PLANE_XZ
	plane.d = self.position.y
	var camera := get_viewport().get_camera_3d() as Camera3D
	var intersect : Variant = plane.intersects_ray(
		camera.project_ray_origin(position_screen),
		camera.project_ray_normal(position_screen)
	)
	if intersect:
		intersect.x = round(intersect.x +0.5)
		intersect.y = 0#round(intersect.y)
		intersect.z = round(intersect.z +0.5)
		selection_placeholder.position = intersect + Vector3(-0.5,0,-0.5)
		structure_placeholder.position = intersect - Vector3(1,0,1)
		var coords = Vector2i(int(intersect.x-1), int(intersect.z-1))
		var is_valid = check_tile_is_valid(coords)
		if is_valid:
			selection_placeholder.show()
		else:
			selection_placeholder.hide()
		if building_rect:
			structure_placeholder.show()
			can_build = tilemap_update(coords, building_rect.size.x, building_rect.size.y, true)
			if can_build:
				structure_placeholder.get_node("SelectionPlaceholder").mesh.material.albedo_color = Color.CHARTREUSE
			else:
				structure_placeholder.get_node("SelectionPlaceholder").mesh.material.albedo_color = Color.RED
		else:
			structure_placeholder.hide()

func check_tile_is_valid(coords: Vector2i) -> bool:
	match surface_map.get_cell_atlas_coords(0, coords):
		Vector2i(2,7):
			# regular rooftop ground
			return true
	return false


func build_structure():

	var file_name = StructureManager.structure_data[building_idx][6]
	var directory_name = file_name.rsplit(".", true, 1)[0]
	var structure2 = load("res://assets/3d/structures/" + directory_name + "/" + file_name)
	if structure2:
		var structure3 = structure2.instantiate()
		structure3.position = structure_placeholder.position + Vector3(building_rect.size.x / 2.0, 0, building_rect.size.y/2.0)
		add_child(structure3)
	var coords = Vector2i(int(structure_placeholder.position.x), int(structure_placeholder.position.z))
	tilemap_update(coords, building_rect.size.x, building_rect.size.y, false)

	# done building
	StructureManager.StructureBuilt.emit(building_idx)
	building_rect = Rect2()
	can_build = false
	building_idx = -1
	structure_placeholder.hide()
	

func tilemap_update(origin: Vector2i,w:int,h:int,check_only:bool=true) -> bool:
	for ix in w:
		for iy in h:
			var coords := origin + Vector2i(ix,iy)
			if check_only:
				if surface_map.get_cell_atlas_coords(0, coords) != Vector2i(2,7):
					return false
			else:
				surface_map.set_cell(0, coords, 0, Vector2i(0,7), 0)
	return true
