extends Node

signal UpdatedAvailableStructures()
signal BuildableStructureSelected(idx: int)
signal StructureBuilt(idx: int)

const BUILDABLE_EMPTY_SPACE = Vector2i(2,7)
const BUILDABLE_RAISED_BED_SPACE = Vector2i(4,7)
const OCCUPIED_SPACE = Vector2i(0,7)
const VALID_TILE_TYPES = [BUILDABLE_EMPTY_SPACE, BUILDABLE_RAISED_BED_SPACE, OCCUPIED_SPACE]


var structure_data = []
var available_structures = []
var registered_characters = []

func _ready() -> void:
	structure_data = _get_structure_data()
	
func register_character_structures(character: String):
	if character in registered_characters:
		return
	registered_characters.append(character)
	for idx in len(structure_data):
		if structure_data[idx][10]==character:
			available_structures.append(idx)
	UpdatedAvailableStructures.emit()
	
func _get_structure_data():
	# this is a copy paste of the CSV exported from Notion
	# Name,priority,height,width,depth,description,model filename,Icon,Art Status,Electricity Generation/Use,Water Generation/Use,Food Generation/Use,Happiness Generation,Electricity Stroage,Water Storage,Food Storage,Cost
	var data_ = """Vegetables	High	0.5	1	1	Small garden bed for growing vegetables	vegetables.tscn	0/0	1	2	Farmer	Concept
Trees	Med	2.5	2	2	Fruit-bearing trees or bushes	apple_tree2.tscn	0/0	1	2	Farmer	Not started
Raised bed		0.5	6	6	Somewhere to plant stuff	raised_bed.tscn	0/0	0	1	Farmer	Not started
Wind turbine/Kite	Med	12	8	8	Tall structure or airborne device generating power from wind	wind_turbine.tscn	2/0	0	2	Electrician	Not started
Water tank	High	3	3	3	Large container for storing clean water	water_tank.tscn	0/2	0	2	Farmer	Not started
Workshop		2.8	4	4	Building for tool use - repair - fabrication	arts_crafts_station.tscn	4/0	0	2	Someone	Not started
Wastewater treatment		3	4	4	Multi-tank system for filtering and purifying greywater	wastewater_treatment.tscn	0/2	0	2	Someone	Not started
Vertical Hydroponics		2.5	2	1	Tower structure for soil-less vertical farming	vertical_hydroponics.tscn	0/3	0	2	Permaculturist	Not started
Solar panel	High	1.2	2	1	Photovoltaic panel for converting sunlight into electricity	solar_panel.tscn	1/0	0	2	Electrician	Concept
Recycling station	High	1.8	2	2	Bins and sorting area for recyclable materials	recycling_station.tscn	0/4	0	2	Someone	Not started
Rain collection	High	2	2	2	Structure for harvesting rainwater - often elevated	rain_collection.tscn	0/2	0	2	Farmer	Concept
Pantry/Storage		2	3	2	Storage shed for food or supplies	pantry_storage.tscn	0/4	0	2	Someone	Not started
Compost		1	2	2	Compost bin or area with regenerative farming tools	composting_regen_agriculture.tscn	3/0	0	2	Permaculturist	Concept
Tent/Yurt/Chill area	High	2.5	5	5	Communal shaded or sheltered resting space	tent_yurt_chill_area.tscn	0/4	0	2	Someone	Not started
Bioreactor		2.5	2	2	Tank system for converting organic matter into energy or fuel	bioreactor.tscn	0/1	0	2	Permaculturist	Concept
Battery	High	1.5	1	1	Power storage unit	battery.tscn	0/1	0	2	Electrician	Not started
Atmospheric water harvesting		2.5	2	2	Device that condenses and collects water from the air	atmospheric_water_harvesting.tscn	0/2	0	2	Farmer	Not started"""
	var data = data_.split("\n")
	data = Array(data)
	for i in len(data):
		data[i] = data[i].split("\t")
		data[i] = Array(data[i])
		for j in [3,4,8,9]:
			data[i][j] = int(data[i][j])
	return data
