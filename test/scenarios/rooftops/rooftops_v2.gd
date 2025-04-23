extends Node3D

var building := Rect2i()
var can_build = false
var cached_world_data = []

func _ready() -> void:
	load_building_palette()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_RIGHT and event.pressed:
		$DayCycle.is_raining = !$DayCycle.is_raining
		$Rain.visible = $DayCycle.is_raining
		$Rain/CanvasLayer.visible = $DayCycle.is_raining
	elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed and building and can_build:
		build_structure()
	elif event is InputEventMouseMotion:
		move_cursor_3d()

func move_cursor_3d():
	var position_screen = get_viewport().get_mouse_position()
	var plane := Plane.PLANE_XZ
	plane.d = -1.0
	var camera := $Player/Camera3D as Camera3D
	var intersect : Variant = plane.intersects_ray(
		camera.project_ray_origin(position_screen),
		camera.project_ray_normal(position_screen)
	)
	if intersect:
		intersect.x = round(intersect.x +0.5)
		intersect.y = round(intersect.y)
		intersect.z = round(intersect.z +0.5)
		intersect.x = clamp(intersect.x, -15, 16)
		intersect.z = clamp(intersect.z, -15, 16)
		$SelectionPlaceholder.position = intersect + Vector3(-0.5,0,-0.5)
		$StructurePlaceholder.position = intersect - Vector3(1,0,1)
	if building:
		$StructurePlaceholder.show()
		can_build = tilemap_update(int($StructurePlaceholder.position.x), int($StructurePlaceholder.position.z), building.size.x, building.size.y, true)
		if can_build:
			$StructurePlaceholder/SelectionPlaceholder.mesh.material.albedo_color = Color.CHARTREUSE
		else:
			$StructurePlaceholder/SelectionPlaceholder.mesh.material.albedo_color = Color.RED
	else:
		$StructurePlaceholder.hide()

@onready var hud := $HUDCanvasLayer as HUDCanvasLayer
func load_building_palette():
	cached_world_data = get_world_data()
	hud.cached_world_data = cached_world_data
	for idx in len(cached_world_data):
		if false:
			var b = Button.new()
			b.connect("pressed", select_structure_from_palette.bind(idx))
			b.text = cached_world_data[idx][0]
			$CanvasLayer/VBoxContainer/VBoxContainer.add_child(b)
		else:
			hud.register_structure(idx)
	hud.connect("BuildableStructureSelected", self.select_structure_from_palette)

func build_structure():
	var structure := $Structure.duplicate() #as MeshInstance3D
	add_child(structure)
	structure.position = $StructurePlaceholder.position
	structure.scale = $StructurePlaceholder.scale
	#structure.mesh = structure.mesh.duplicate()
	#var x := structure.mesh
	#x.material = x.material.duplicate()
	#x.material.albedo_color.b = randf() * 0.5
	tilemap_update(int(structure.position.x), int(structure.position.z), building.size.x, building.size.y, false)
	# done building
	building = Rect2()
	$StructurePlaceholder.hide()

func tilemap_update(x,y,w,h,check_only=true):
	for ix in w:
		for iy in h:
			var coords := Vector2i(x+ix,y+iy)
			if check_only:
				if $CanvasLayer/Node2D/TileMap.get_cell_atlas_coords(0, coords) != Vector2i(2,7):
					return false
			else:
				$CanvasLayer/Node2D/TileMap.set_cell(0, coords, 0, Vector2i(0,7), 0)
	return true


func select_structure_from_palette(idx):
	$CanvasLayer/VBoxContainer/Label.text = "Now building " + cached_world_data[idx][0]
	$StructurePlaceholder.show()
	building = Rect2i(0,0,cached_world_data[idx][3],cached_world_data[idx][4])
	$StructurePlaceholder.scale = Vector3(building.size.x, 1, building.size.y)
	can_build = true
	

func select_structure_from_world():
	# TODO open the structure-specific menu here
	pass

static func get_world_data():
	# Name,priority,height,width,depth,description,model filename,Icon,Art Status,Electricity Generation/Use,Water Generation/Use,Food Generation/Use,Happiness Generation,Electricity Stroage,Water Storage,Food Storage,Cost
	var data_ = """Workshop,,2.8,4,4,Building for tool use - repair - fabrication,workshop.tscn,4/0,Not started,,,,,,,,
Wind turbine/Kite,Med,12,8,8,Tall structure or airborne device generating power from wind,wind_turbine_or_kite.tscn,2/0,Not started,,,,,,,,
Water tank,High,3,3,3,Large container for storing clean water,water_tank.tscn,0/2,Not started,,,,,,100,,
Wastewater treatment,,3,4,4,Multi-tank system for filtering and purifying greywater,wastewater_treatment.tscn,0/2,Not started,,,,,,,,
Vertical Hydroponics,,2.5,2,1,Tower structure for soil-less vertical farming,vertical_hydroponics.tscn,0/3,Not started,,,,,,,,
Vegetable garden,High,0.5,3,2,Small garden bed for growing vegetables,vegetable_garden.tscn,0/0,Concept,,,,,,,,
Tent/Yurt/Chill area,High,2.5,5,5,Communal shaded or sheltered resting space,tent_yurt_chill_area.tscn,0/4,Not started,,,,,,,,
Solar panel,High,1.2,2,1,Photovoltaic panel for converting sunlight into electricity,solar_panel.tscn,1/0,Concept,,,,,,,,
Recycling station,High,1.8,2,2,Bins and sorting area for recyclable materials,recycling_station.tscn,0/4,Not started,,,,,,,,
Rain collection,High,2,2,2,Structure for harvesting rainwater - often elevated,rain_collection.tscn,0/2,Concept,,,,,,,,
Pantry/Storage,,2,3,2,Storage shed for food or supplies,pantry_storage.tscn,0/4,Not started,,,,,,,100,
Kitchen,High,2.5,4,3,Communal cooking space with equipment,kitchen.tscn,0/4,Not started,,,,,,,,"""

	var data__ = """Hygiene station,,2,2,2,Outdoor sink/shower area for personal hygiene,hygiene_station.tscn,0/4,Not started,,,,,,,,
Garbage dump,,1,3,3,Area for non-recyclable waste,garbage_dump.tscn,0/4,Not started,,,,,,,,
Fruit bushes/trees,Med,2.5,3,3,Fruit-bearing trees or bushes,fruit_bushes_trees.tscn,0/0,Not started,,,,,,,,
Fermentation,,1.8,1,1,Small structure with sealed containers for fermentation,fermentation.tscn,0/3,Not started,,,,,,,,
Exercise station,,2.5,3,3,Outdoor space with equipment for physical activity,exercise_station.tscn,0/4,Not started,,,,,,,,
Compost,,1,2,2,Compost bin or area with regenerative farming tools,composting_regen_agriculture.tscn,3/0,Concept,,,,,,,,
Bioreactor,,2.5,2,2,Tank system for converting organic matter into energy or fuel,bioreactor.tscn,0/1,Concept,,,,,,,,
Battery,High,1.5,1,1,Power storage unit,battery.tscn,0/1,Not started,,,,,100,,,
Atmospheric water harvesting,,2.5,2,2,Device that condenses and collects water from the air,atmospheric_water_harvesting.tscn,0/2,Not started,,,,,,,,
Arts and crafts station,,2,3,3,Covered station with tools for creative work,arts_crafts_station.tscn,0/4,Not started,,,,,,,,
Aquaponics,,1.5,3,2,Combined fish and plant growing system,aquaponics.tscn,0/3,Not started,,,,,,,,"""
	var data = data_.split("\n")
	data = Array(data)
	for i in len(data):
		data[i] = data[i].split(",")
		data[i] = Array(data[i])
		for j in 2:
			data[i][j+3] = int(data[i][j+3])
	return data
