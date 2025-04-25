extends Node

signal BuildableStructureSelected(idx: int)
signal StructureBuilt(idx: int)

var structure_data = []

func _ready() -> void:
	structure_data = _get_structure_data()
	
func _get_structure_data():
	# this is a copy paste of the CSV exported from Notion
	# Name,priority,height,width,depth,description,model filename,Icon,Art Status,Electricity Generation/Use,Water Generation/Use,Food Generation/Use,Happiness Generation,Electricity Stroage,Water Storage,Food Storage,Cost
	var data_ = """Vegetable garden,High,0.5,3,2,Small garden bed for growing vegetables,vegetable_garden.tscn,0/0,Concept,,,,,,,,
Workshop,,2.8,4,4,Building for tool use - repair - fabrication,arts_crafts_station.tscn,4/0,Not started,,,,,,,,
Fruit bushes/trees,Med,2.5,3,3,Fruit-bearing trees or bushes,apple_tree.tscn,0/0,Not started,,,,,,,,
Wind turbine/Kite,Med,12,8,8,Tall structure or airborne device generating power from wind,wind_turbine.tscn,2/0,Not started,,,,,,,,
Water tank,High,3,3,3,Large container for storing clean water,water_tank.tscn,0/2,Not started,,,,,,100,,
Wastewater treatment,,3,4,4,Multi-tank system for filtering and purifying greywater,wastewater_treatment.tscn,0/2,Not started,,,,,,,,
Vertical Hydroponics,,2.5,2,1,Tower structure for soil-less vertical farming,vertical_hydroponics.tscn,0/3,Not started,,,,,,,,
Tent/Yurt/Chill area,High,2.5,5,5,Communal shaded or sheltered resting space,tent_yurt_chill_area.tscn,0/4,Not started,,,,,,,,
Solar panel,High,1.2,2,1,Photovoltaic panel for converting sunlight into electricity,solar_panel.tscn,1/0,Concept,,,,,,,,
Recycling station,High,1.8,2,2,Bins and sorting area for recyclable materials,recycling_station.tscn,0/4,Not started,,,,,,,,
Rain collection,High,2,2,2,Structure for harvesting rainwater - often elevated,rain_collection.tscn,0/2,Concept,,,,,,,,
Pantry/Storage,,2,3,2,Storage shed for food or supplies,pantry_storage.tscn,0/4,Not started,,,,,,,100,
Kitchen,High,2.5,4,3,Communal cooking space with equipment,kitchen.tscn,0/4,Not started,,,,,,,,
Hygiene station,,2,2,2,Outdoor sink/shower area for personal hygiene,hygiene_station.tscn,0/4,Not started,,,,,,,,
Garbage dump,,1,3,3,Area for non-recyclable waste,garbage_dump.tscn,0/4,Not started,,,,,,,,
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
