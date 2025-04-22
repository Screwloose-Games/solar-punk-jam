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
		intersect.x = round(intersect.x)
		intersect.y = round(intersect.y)
		intersect.z = round(intersect.z)
		intersect.x = clamp(intersect.x, -15.5, 15.5)
		intersect.z = clamp(intersect.z, -15.5, 15.5)
		$SelectionPlaceholder.position = intersect
		$StructurePlaceholder.position = intersect + Vector3(-0.5,0,-0.5)

func load_building_palette():
	cached_world_data = get_world_data()
	for idx in len(cached_world_data):
		var b = Button.new()
		b.connect("pressed", select_structure_from_palette.bind(idx))
		b.text = cached_world_data[idx][0]
		$CanvasLayer/VBoxContainer/VBoxContainer.add_child(b)

func build_structure():
	var structure := $Structure.duplicate() as MeshInstance3D
	add_child(structure)
	structure.position = $SelectionPlaceholder.position
	structure.mesh = structure.mesh.duplicate()
	var x := structure.mesh
	x.material = x.material.duplicate()
	x.material.albedo_color.b = randf() * 0.5

func select_structure_from_palette(idx):
	$CanvasLayer/VBoxContainer/Label.text = "Now building " + cached_world_data[idx][0]
	$StructurePlaceholder.show()
	building = Rect2i(0,0,cached_world_data[idx][3],cached_world_data[idx][4])
	$StructurePlaceholder.scale = Vector3(building.size.x, 1, building.size.y)
	

func select_structure_from_world():
	# TODO open the structure-specific menu here
	pass

static func get_world_data():
	# name,priority,height,width,depth,description,filename
	var data_ = """Workshop,,2.8,4,4,Building for tool use - repair - fabrication,workshop.tscn
Wind turbine/Kite,Med,12,3,3,Tall structure or airborne device generating power from wind,wind_turbine_or_kite.tscn
Water tank,High,3,3,3,Large container for storing clean water,water_tank.tscn
Wastewater treatment,,3,4,4,Multi-tank system for filtering and purifying greywater,wastewater_treatment.tscn
Vertical Hydroponics,,2.5,2,1,Tower structure for soil-less vertical farming,vertical_hydroponics.tscn
Vegetable garden,High,0.5,3,2,Small garden bed for growing vegetables,vegetable_garden.tscn
Tent/Yurt/Chill area,High,2.5,5,5,Communal shaded or sheltered resting space,tent_yurt_chill_area.tscn
Solar panel,High,1.2,2,1,Photovoltaic panel for converting sunlight into electricity,solar_panel.tscn
Recycling station,High,1.8,2,2,Bins and sorting area for recyclable materials,recycling_station.tscn
Rain collection,High,2,2,2,Structure for harvesting rainwater - often elevated,rain_collection.tscn
Pantry/Storage,,2,3,2,Storage shed for food or supplies,pantry_storage.tscn
Kitchen,High,2.5,4,3,Communal cooking space with equipment,kitchen.tscn
Hygiene station,,2,2,2,Outdoor sink/shower area for personal hygiene,hygiene_station.tscn
Garbage dump,,1,3,3,Area for non-recyclable waste,garbage_dump.tscn
Fruit bushes/trees,Med,2.5,3,3,Fruit-bearing trees or bushes,fruit_bushes_trees.tscn
Fermentation,,1.8,1,1,Small structure with sealed containers for fermentation,fermentation.tscn
Exercise station,,2.5,3,3,Outdoor space with equipment for physical activity,exercise_station.tscn
Composting and regenerative agriculture,,1,2,2,Compost bin or area with regenerative farming tools,composting_regen_agriculture.tscn
Bioreactor,,2.5,2,2,Tank system for converting organic matter into energy or fuel,bioreactor.tscn
Battery,High,1.5,1,1,Power storage unit,battery.tscn
Atmospheric water harvesting,,2.5,2,2,Device that condenses and collects water from the air,atmospheric_water_harvesting.tscn
Arts and crafts station,,2,3,3,Covered station with tools for creative work,arts_crafts_station.tscn
Aquaponics,,1.5,3,2,Combined fish and plant growing system,aquaponics.tscn"""
	var data = data_.split("\n")
	data = Array(data)
	for i in len(data):
		data[i] = data[i].split(",")
		data[i] = Array(data[i])
		for j in 2:
			data[i][j+3] = int(data[i][j+3])
	return data
