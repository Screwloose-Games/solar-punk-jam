extends Node

enum BUILD_STATUS {BUILDING, WORKING}

class BuiltStructure:
	var surface: BuildableSurface
	var coords: Vector2i
	var structure: int
	var build_day: int
	var build_status: BUILD_STATUS
	var ready_to_be_collected: Array
	func _init(surface, coords, structure_id, build_day, build_status) -> void:
		self.surface = surface
		self.coords = coords
		self.structure = structure_id
		self.build_day = build_day
		self.build_status = build_status
		self.ready_to_be_collected = []
	func collect_today():
		for i in self.ready_to_be_collected:
			EnvironmentManager.gain_resource(i, 1)
		self.ready_to_be_collected = []
		HUDCanvasLayer.Singleton.instance.close_popup_menu()
		
		
var built_structures : Array[BuiltStructure] = []

signal UpdatedAvailableStructures()
signal BuildableStructureSelected(idx: int)
signal StructureBuilt(s: BuiltStructure)

const BUILDABLE_EMPTY_SPACE = Vector2i(2,7)
const BUILDABLE_RAISED_BED_SPACE = Vector2i(4,7)
const OCCUPIED_SPACE = Vector2i(0,7)
const VALID_TILE_TYPES = [BUILDABLE_EMPTY_SPACE, BUILDABLE_RAISED_BED_SPACE, OCCUPIED_SPACE]


var structure_data = []
var available_structures = []
var registered_characters = []


func _ready() -> void:
	structure_data = _get_structure_data()
	EnvironmentManager.connect("day_cycle_start", daily_collect_resources_from_structures)

func check_structure_requirements(idx):
	var requirement = StructureManager.structure_data[idx][StructureManager.STRUCTURE_FIELDS.BuildingConsumes]
	#prints("check_structure_requirements", idx, requirement)
	if requirement:
		if EnvironmentManager.check_amount(requirement, 1):
			return []
		else:
			# We do not have enough
			return [requirement]
	else:
		return []


func register_character_structures(character: String):
	prints("Unlocking structures from", character)
	if character in registered_characters:
		return
	registered_characters.append(character)
	for idx in len(structure_data):
		if structure_data[idx][StructureManager.STRUCTURE_FIELDS.UnlockedBy]==character:
			available_structures.append(idx)
	UpdatedAvailableStructures.emit()

func build_structure(new_structure: BuiltStructure):
	EnvironmentManager.gain_resource("Materials", -structure_data[new_structure.structure][StructureManager.STRUCTURE_FIELDS.MaterialCost])
	EnvironmentManager.gain_resource(structure_data[new_structure.structure][StructureManager.STRUCTURE_FIELDS.BuildingConsumes], -1)
	built_structures.append(new_structure)
	StructureBuilt.emit(new_structure)

func daily_collect_resources_from_structures():
	for structure in built_structures:
		var record = structure_data[structure.structure]
		# ["Electricity", "Water", "Food", "Waste", "Soil", "Happiness", "Materials", "Seeds"]
		# "Electricity, Water, Food, Waste, Soil, Happiness"
		for i in 6:
			var q = record[STRUCTURE_FIELDS.Electricity + i]
			if q != 0:
				EnvironmentManager.gain_resource(EnvironmentManager.resources[i], q)
		# reset manual collection
		if structure_data[structure.structure][STRUCTURE_FIELDS.DailyManualCollection]:
			structure.ready_to_be_collected = [structure_data[structure.structure][STRUCTURE_FIELDS.DailyManualCollection]]
		else:
			structure.ready_to_be_collected = []
		
		

enum STRUCTURE_FIELDS {StructureName, StructureHeight, StructureWidth, StructureDepth, StructureDescription, StructureModel, StructureIcon, GroundBefore, GroundAfter, InitialHappiness, MaxStructures, UnlockedBy, MaterialCost, Requirements, DaysToComplete, Electricity, Water, Food, Waste, Soil, Happiness, BuildingConsumes, DailyManualCollection}


func _get_structure_data():
	# this is a copy paste of the CSV exported from Notion
	# Name,priority,height,width,depth,description,model filename,Icon,Art Status,Electricity Generation/Use,Water Generation/Use,Food Generation/Use,Happiness Generation,Electricity Stroage,Water Storage,Food Storage,Cost
	var data_ = """Battery	1.5	1	1	Power storage unit	battery.tscn	0,1	0	2	10	3	Electrician	1	Solar panel	2	1					0		
Bench	2.8	4	4	TBD	arts_crafts_station.tscn	0,4	0	2	5		Contractor	2		1						0		
Bioreactor	2.5	2	2	Tank system for converting organic matter into energy or fuel	bioreactor.tscn	0,1	0	2	10	1	Electrician	3	Solar panel	3	1					0		
Birdhouse (on pole)	2	2	2	Structure for harvesting rainwater - often elevated	rain_collection.tscn	0,2	0	2	2		Craftor	1		1						0		
Bush (flowers)	2.5	2	2	TBD	apple_tree2.tscn	0,0	1	2	2		Seeds	0		1			1			0	Seeds	Food
Compost bin	1	2	2	Compost bin or area with regenerative farming tools	composting_regen_agriculture.tscn	3,0	0	2	1	5	Contractor	2		1				-1	1	0		Soil
Hygiene station	2	2	2	Outdoor sink/shower area for personal hygiene	hygiene_station.tscn	0,4	0	2	10	2	Plumber	2	Rain barrel	3						0		
Insect Hotel	2	2	2	Structure for harvesting rainwater - often elevated	rain_collection.tscn	0,2	0	2	2		Craftor	1		1						0		
Kitchen prep area	2.8	4	4	TBD	arts_crafts_station.tscn	0,4	0	2	5	1	Contractor	5		3						0		
Kitchen sink	2.8	4	4	TBD	arts_crafts_station.tscn	0,4	0	2	5	1	Plumber	5	Rain barrel	3						0		
Kitchen stove	2.8	4	4	TBD	arts_crafts_station.tscn	0,4	0	2	5	1	Electrician	5	Solar panel	3						0		
Lantern (on pole)	2	2	2	Structure for harvesting rainwater - often elevated	rain_collection.tscn	0,2	0	2	2		Craftor	1		1						0		
Picnic Table	2.8	4	4	TBD	arts_crafts_station.tscn	0,4	0	2	5		Contractor	3		2						0		
Rain barrel	2	2	2	Structure for harvesting rainwater - often elevated	rain_collection.tscn	0,2	0	2	1	5	Contractor	1		1		1				0		
Raised bed	0.5	6	6	Somewhere to plant stuff	raised_bed.tscn	0,0	0	1	1	25	Contractor	3		1							Soil	
Vertical garden	0.5	1	1	Somewhere to plant stuff	arts_crafts_station.tscn	0,0	0	1	1	25	Contractor	3		1						0		
Recycling station	1.8	2	2	Bins and sorting area for recyclable materials	recycling_station.tscn	0,4	0	2	10	1	Contractor	4	Solar panel	3						0		
Solar panel	1.2	2	1	Photovoltaic panel for converting sunlight into electricity	solar_panel.tscn	1,0	0	2	10	3	Electrician	4		2	1					0		
Tool library	2.8	4	4	TBD	arts_crafts_station.tscn	0,4	0	2	5	1	Contractor	2		1						0		
Tree	2.5	2	2	Fruit-bearing trees or bushes	apple_tree2.tscn	0,0	1	2	2		Seeds	0		1			1			0	Seeds	Food
Vegetables	0.5	1	1	Small garden bed for growing vegetables	vegetables.tscn	0,0	1	2	2		Seeds	0		1			1			0	Seeds	Food"""
	var data = data_.split("\n")
	data = Array(data)
	for i in len(data):
		data[i] = data[i].split("\t")
		data[i] = Array(data[i])
		for j in [STRUCTURE_FIELDS.StructureWidth, STRUCTURE_FIELDS.StructureDepth, STRUCTURE_FIELDS.GroundBefore, STRUCTURE_FIELDS.GroundAfter, STRUCTURE_FIELDS.InitialHappiness, STRUCTURE_FIELDS.MaterialCost, STRUCTURE_FIELDS.DaysToComplete, STRUCTURE_FIELDS.Electricity, STRUCTURE_FIELDS.Water, STRUCTURE_FIELDS.Food, STRUCTURE_FIELDS.Waste, STRUCTURE_FIELDS.Soil, STRUCTURE_FIELDS.Happiness]:
			data[i][j] = int(data[i][j])
	return data
