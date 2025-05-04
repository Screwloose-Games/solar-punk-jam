extends Node3D
class_name BuildableSurface

@onready var selection_placeholder := $SelectionPlaceholder as Node3D
@onready var structure_placeholder := $StructurePlaceholder as Node3D
@onready var preview_buildable_area := $Preview as Node3D
@onready var surface_map := $SurfaceMap as TileMap

@export_multiline var initial_build := ""
@export var is_active := false:
	set(value):
		is_active = value
		if is_active:
			enable_cursor_3d()
			if preview_buildable_area:
				preview_buildable_area.show()
		else:
			if selection_placeholder:
				selection_placeholder.hide()
				structure_placeholder.hide()
				preview_buildable_area.hide()

var building_rect := Rect2i()
var building_idx := -1
var can_build = false
var can_check = false
var can_walk = false
var current_coords = Vector2.ZERO

var built_structures_local : Array[StructureManager.BuiltStructure] = []
var tile_to_structure_idx: Dictionary[Vector2i, int]= {} # coords, structure_id


func _ready() -> void:
	StructureManager.BuildableStructureSelected.connect(ready_structure_building)
	selection_placeholder.hide()
	structure_placeholder.hide()
	create_preview()
	create_initial_build()
	if is_active:
		StructureManager.set_active_surface(self)

func create_preview():
	var preview = $Preview
	var preview2 = $AlwaysOnPreview
	for coords in surface_map.get_used_cells(0):
		var visual_instance = $Preview/Preview.duplicate()
		visual_instance.position.x = coords.x + 0.5
		visual_instance.position.z = coords.y + 0.5
		visual_instance.show()
		preview.add_child(visual_instance)
		var visual_instance2 = $AlwaysOnPreview/Preview.duplicate()
		visual_instance2.position.x = coords.x + 0.5
		visual_instance2.position.z = coords.y + 0.5
		visual_instance2.show()
		preview2.add_child(visual_instance2)
	preview.visible = is_active

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:
		if can_build:
			build_structure()
		elif can_check:
			structure_popup()
	elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_RIGHT and event.pressed:
		reset_cursor_3d()
	elif event is InputEventMouseMotion:
		move_cursor_3d()

func structure_popup():
	var structure_id: int = tile_to_structure_idx[Vector2i(current_coords)]
	var structure: StructureManager.BuiltStructure = built_structures_local[structure_id]
	HUDCanvasLayer.Singleton.instance.kill_tool_tip()
	HUDCanvasLayer.Singleton.instance.show_popup_menu(structure)
	#StructureManager.structure_data[structure.structure][StructureManager.STRUCTURE_FIELDS.StructureName], position_screen)

func ready_structure_building(idx):
	if not is_active:
		return
	if StructureManager.check_structure_requirements(idx):
		return
	structure_placeholder.show()
	var w = int(StructureManager.structure_data[idx][StructureManager.STRUCTURE_FIELDS.StructureWidth])
	var h = int(StructureManager.structure_data[idx][StructureManager.STRUCTURE_FIELDS.StructureDepth])
	building_rect = Rect2i(0,0,w,h)
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
		selection_placeholder.position = intersect + Vector3(-0.5+position.x,0,-0.5+position.z)
		structure_placeholder.position = intersect - Vector3(1+position.x,0,1+position.z)
		intersect.x -= position.x
		intersect.z -= position.z
		var coords = Vector2i(int(intersect.x-1), int(intersect.z-1))
		can_check = false
		var is_valid = check_tile_is_valid(coords)
		if building_rect:
			structure_placeholder.show()
			selection_placeholder.hide()
			#can_build = surface_check(coords, building_rect.size.x, building_rect.size.y, StructureManager.BUILDABLE_EMPTY_SPACE, Vector2i.ZERO)
			can_build = surface_check(coords, building_rect.size.x, building_rect.size.y, StructureManager.VALID_TILE_TYPES[StructureManager.structure_data[building_idx][StructureManager.STRUCTURE_FIELDS.GroundBefore]], Vector2i.ZERO)
			if can_build:
				structure_placeholder.get_node("SelectionPlaceholder").mesh.material.albedo_color = Color.CHARTREUSE
				structure_placeholder.get_node("SelectionPlaceholder/SelectionPlaceholder").mesh.material.albedo_color = Color.CHARTREUSE
				structure_placeholder.get_node("SelectionPlaceholder/SelectionPlaceholder").mesh.material.albedo_color.a = 0.33
			else:
				structure_placeholder.get_node("SelectionPlaceholder").mesh.material.albedo_color = Color.RED
				structure_placeholder.get_node("SelectionPlaceholder/SelectionPlaceholder").mesh.material.albedo_color = Color.RED
				structure_placeholder.get_node("SelectionPlaceholder/SelectionPlaceholder").mesh.material.albedo_color.a = 0.33
		else:
			structure_placeholder.hide()
			if is_valid:
				selection_placeholder.show()
				if coords in tile_to_structure_idx:
					can_check = true
					current_coords = coords
					var structure = built_structures_local[tile_to_structure_idx[current_coords]]
					HUDCanvasLayer.Singleton.instance.set_tool_tip(StructureManager.structure_data[structure.structure][StructureManager.STRUCTURE_FIELDS.StructureName], position_screen)
			else:
				selection_placeholder.hide()

func check_tile_is_valid(coords: Vector2i) -> bool:
	var tile_kind = surface_map.get_cell_atlas_coords(0, coords)
	return tile_kind in StructureManager.VALID_TILE_TYPES

func create_initial_build():
	if initial_build:
		for record in initial_build.split("\n"):
			var data = record.split("\t")
			var coords = data[1].split(",")
			building_idx = StructureManager.structure_name_to_idx_map[data[0]]
			var coords_ = Vector2i(int(coords[0].strip_edges()), int(coords[1].strip_edges()))
			#coords_ += Vector2i.ONE
			var w = int(StructureManager.structure_data[building_idx][StructureManager.STRUCTURE_FIELDS.StructureWidth])
			var h = int(StructureManager.structure_data[building_idx][StructureManager.STRUCTURE_FIELDS.StructureDepth])
			building_rect = Rect2i(0,0,w,h)
			_build_structure(building_idx, coords_, building_rect, true)
	reset_cursor_3d()


func build_structure():
	var coords = Vector2i(int(structure_placeholder.position.x), int(structure_placeholder.position.z))
	_build_structure(building_idx, coords, building_rect)

	# done building
	if StructureManager.check_structure_requirements(building_idx):
		reset_cursor_3d()
	else:
		pass
		# to let build the same again, comment the following line
		reset_cursor_3d()

func _build_structure(building_idx, coords, building_rect, skip_resource_consumption=false):
	prints("building structure at",coords)
	var file_name = StructureManager.structure_data[building_idx][StructureManager.STRUCTURE_FIELDS.StructureModel]
	var directory_name = file_name.rsplit(".", true, 1)[0]
	var visual_instance = null
	var visual_instance_scene = load("res://assets/3d/structures/" + directory_name + "/" + file_name)
	if visual_instance_scene:
		visual_instance = visual_instance_scene.instantiate()
		visual_instance.position = Vector3(coords.x, 0, coords.y) + Vector3(building_rect.size.x / 2.0, 0, building_rect.size.y/2.0)
		add_child(visual_instance)
	surface_check(coords, building_rect.size.x, building_rect.size.y, Vector2i.ZERO, StructureManager.VALID_TILE_TYPES[StructureManager.structure_data[building_idx][StructureManager.STRUCTURE_FIELDS.GroundAfter]])

	var new_structure = StructureManager.BuiltStructure.new(self, coords, building_idx, EnvironmentManager.environment_model.day, StructureManager.STRUCTURE_STATUS.JUST_CREATED, visual_instance)
	built_structures_local.append(new_structure)
	register_tiles(len(built_structures_local)-1, coords, building_rect.size.x, building_rect.size.y)
	StructureManager.build_structure(new_structure, skip_resource_consumption)

func register_tiles(structure_idx:int, origin: Vector2i, w:int, h:int):
	for ix in w:
		for iy in h:
			var coords := origin + Vector2i(ix,iy)
			tile_to_structure_idx[coords]=structure_idx

func reset_cursor_3d():
	building_rect = Rect2()
	can_build = false
	building_idx = -1
	structure_placeholder.hide()

func collect_today():
	for structure in built_structures_local:
		structure.collect_today()

func surface_check(origin: Vector2i, w:int, h:int, required_kind: Vector2i, update_kind: Vector2i) -> bool:
	for ix in w:
		for iy in h:
			var coords := origin + Vector2i(ix,iy)
			if required_kind!=Vector2i.ZERO:
				if surface_map.get_cell_atlas_coords(0, coords) != required_kind:
					return false
			else:
				surface_map.set_cell(0, coords, 0, update_kind, 0)
	return true
