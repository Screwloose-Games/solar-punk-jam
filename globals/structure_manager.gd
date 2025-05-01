extends Node

enum BUILD_STATUS {BUILDING, WORKING}

class BuiltStructure:
	var surface: BuildableSurface
	var coords: Vector2i
	var structure: int
	var build_day: int
	var build_status: BUILD_STATUS
	var ready_to_be_collected: Array
	var daily_resources_satisfied: bool
	var visual_instance: Node3D
	func _init(surface, coords, structure_id, build_day, build_status, visual_instance) -> void:
		self.surface = surface
		self.coords = coords
		self.structure = structure_id
		self.build_day = build_day
		self.build_status = build_status
		self.visual_instance = visual_instance
		self.daily_resources_satisfied = true
		self.ready_to_be_collected = []
	func collect_today():
		for i in self.ready_to_be_collected:
			EnvironmentManager.gain_resource(i, 1)
		self.ready_to_be_collected = []
		HUDCanvasLayer.Singleton.instance.close_popup_menu()
	func refill_today():
		if StructureManager.check_structure_requirements(self.structure):
			var requirements = StructureManager.structure_data[self.structure][StructureManager.STRUCTURE_FIELDS.BuildingConsumes]
			for item in requirements.split(","):
				if StructureManager.structure_data[self.structure][StructureManager.STRUCTURE_FIELDS.ConsumesAllInventory]:
					# This currently only applies to the donation box, tweak if necessary
					EnvironmentManager.gain_resource(item, -1*EnvironmentManager.current_resources[item])
					EnvironmentManager.deposit_resource(item, 1*EnvironmentManager.current_resources[item])
				else:
					EnvironmentManager.gain_resource(item, -1)
			self.daily_resources_satisfied = true
			return true
		else:
			return false
		
		
var built_structures : Array[BuiltStructure] = []
var current_active_surface = null

func set_active_surface(surface):
	prints("set_active_surface", surface, surface.name, surface.is_active)
	if surface == current_active_surface:
		return
	if current_active_surface:
		current_active_surface.is_active = false
	current_active_surface = surface

signal UpdatedAvailableStructures()
signal BuildableStructureSelected(idx: int)
signal StructureBuilt(s: BuiltStructure)

const BUILDABLE_EMPTY_SPACE = Vector2i(2,7)
const BUILDABLE_RAISED_BED_SPACE = Vector2i(4,7)
const OCCUPIED_SPACE = Vector2i(0,7)
const VALID_TILE_TYPES = [BUILDABLE_EMPTY_SPACE, BUILDABLE_RAISED_BED_SPACE, OCCUPIED_SPACE]


var structure_data = []
var structure_name_to_idx_map = {}
var available_structures = []
var registered_structures = []

func _ready() -> void:
	structure_data = _get_structure_data()
	for idx in len(structure_data):
		structure_name_to_idx_map[structure_data[idx][STRUCTURE_FIELDS.StructureName]] = idx
		
	EnvironmentManager.connect("day_cycle_start", daily_collect_resources_from_structures)

func check_structure_requirements(idx):
	var requirements = StructureManager.structure_data[idx][StructureManager.STRUCTURE_FIELDS.BuildingConsumes]
	var missing_requirements = []
	if requirements:
		for requirement in requirements.split(","):
			if EnvironmentManager.check_amount(requirement, 1):
				# We have enough
				pass
			else:
				# We do not have enough
				missing_requirements.append(requirement)
	# Will return [] if all requirements are satisfied
	return missing_requirements


func register_structure(struct_name : String):
	print("Unlocking structure: %s" % struct_name)
	if struct_name in registered_structures:
		return
	registered_structures.append(struct_name)
	for idx in len(structure_data):
		if structure_data[idx][StructureManager.STRUCTURE_FIELDS.StructureName] == struct_name:
			available_structures.append(idx)
	UpdatedAvailableStructures.emit()


func register_character_structures(character: String):
	prints("Unlocking structures from", character)
	for idx in len(structure_data):
		if structure_data[idx][StructureManager.STRUCTURE_FIELDS.UnlockedBy]==character:
			var struct_name = structure_data[idx][StructureManager.STRUCTURE_FIELDS.StructureName]
			register_structure(struct_name)
	UpdatedAvailableStructures.emit()


func build_structure(new_structure: BuiltStructure):
	if structure_data[new_structure.structure][StructureManager.STRUCTURE_FIELDS.MaterialCost] > 0:
		EnvironmentManager.gain_resource("Materials", -structure_data[new_structure.structure][StructureManager.STRUCTURE_FIELDS.MaterialCost])
	var requirements = StructureManager.structure_data[new_structure.structure][StructureManager.STRUCTURE_FIELDS.BuildingConsumes]
	if requirements:
		for item in requirements.split(","):
			EnvironmentManager.gain_resource(item, -1)
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
		structure.ready_to_be_collected = []
		if structure_data[structure.structure][STRUCTURE_FIELDS.DailyManualCollection]:
			# Handle the waste bin separately
			if structure_data[structure.structure][STRUCTURE_FIELDS.StructureName]=="Waste bin":
				# convert environment food donation to waste and seeds
				for donated_item in EnvironmentManager.deposited_resources:
					for donated_quantity in EnvironmentManager.deposited_resources[donated_item]:
						for item in structure_data[structure.structure][STRUCTURE_FIELDS.DailyManualCollection].split(","):
							for count in structure_data[structure.structure][STRUCTURE_FIELDS.DailyManualCollectionMultiplier]:
								structure.ready_to_be_collected.append(item)
				# clear donated resources
				EnvironmentManager.deposited_resources = {}
			else:
				if not structure_data[structure.structure][STRUCTURE_FIELDS.RequiresRefill] or structure_data[structure.structure][STRUCTURE_FIELDS.RequiresRefill] and structure.daily_resources_satisfied:
					for item in structure_data[structure.structure][STRUCTURE_FIELDS.DailyManualCollection].split(","):
						for count in structure_data[structure.structure][STRUCTURE_FIELDS.DailyManualCollectionMultiplier]:
							structure.ready_to_be_collected.append(item)
		
		

enum STRUCTURE_FIELDS {StructureName, StructureHeight, StructureWidth, StructureDepth, StructureDescription, StructureModel, StructureIcon, GroundBefore, GroundAfter, InitialHappiness, MaxStructures, UnlockedBy, MaterialCost, Requirements, DaysToComplete, Electricity, Water, Food, Waste, Soil, Happiness, BuildingConsumes, DailyManualCollection, DailyManualCollectionMultiplier, RequiresRefill, ConsumesAllInventory}


func _get_structure_data():
	# this is a copy paste of the CSV exported from Notion
	# Name,priority,height,width,depth,description,model filename,Icon,Art Status,Electricity Generation/Use,Water Generation/Use,Food Generation/Use,Happiness Generation,Electricity Stroage,Water Storage,Food Storage,Cost
	var data_ = """Battery	1.5	1	1	Power storage unit	battery.tscn	0,1	0	2	10	3	Electrician	1	Solar panel	2	10					0					
Bench	2.8	4	4	TBD	arts_crafts_station.tscn	0,4	0	2	5		Contractor	2		1						0					
Bioreactor	2.5	2	2	Tank system for converting organic matter into energy or fuel	bioreactor.tscn	0,1	0	2	10	1	Electrician	3	Solar panel	3	10					0					
Birdhouse (on pole)	2	2	2	Structure for harvesting rainwater - often elevated	rain_collection.tscn	0,2	0	2	2		Craftor	1		1						0					
Bush (flowers)	2.5	2	2	TBD	apple_tree2.tscn	0,0	1	2	2		Seeds	0		1						0	Seeds	Food			
Compost bin	1	2	2	Compost bin or area with regenerative farming tools	donation_bin.tscn	3,0	0	2	1	5	Contractor	2		1						0	Waste	Soil	5	1	
Hygiene station	2	2	2	Outdoor sink/shower area for personal hygiene	hygiene_station.tscn	0,4	0	2	10	2	Plumber	2	Rain barrel	3						0					
Insect Hotel	2	2	2	Structure for harvesting rainwater - often elevated	rain_collection.tscn	0,2	0	2	2		Craftor	1		1						0					
Kitchen 	2.8	4	4	TBD	arts_crafts_station.tscn	0,4	0	2	10	1	Contractor	5	Solar panel	3						0					
Kitchen sink	2.8	4	4	TBD	arts_crafts_station.tscn	0,4	0	2	5	1	Plumber	5	Rain barrel	3						0					
Kitchen stove	2.8	4	4	TBD	arts_crafts_station.tscn	0,4	0	2	5	1	Electrician	5	Solar panel	3						0					
Lantern (on pole)	2	2	2	Structure for harvesting rainwater - often elevated	rain_collection.tscn	0,2	0	2	2		Craftor	1		1						0					
Picnic Table	2.8	4	4	TBD	arts_crafts_station.tscn	0,4	0	2	5		Contractor	3		2						0					
Rain barrel	2	2	2	Structure for harvesting rainwater - often elevated	rain_barrel.tscn	0,2	0	2	1	5	Contractor	1		1		10				0		Water	3		
Raised bed	0.5	6	6	Somewhere to plant stuff	raised_bed.tscn	0,0	0	1	1	25	Contractor	3		1						0	Soil				
Vertical garden	0.5	1	1	Somewhere to plant stuff	arts_crafts_station.tscn	0,0	0	1	1	25	Contractor	3		1						0					
Recycling station	1.8	2	2	Bins and sorting area for recyclable materials	recycling_station.tscn	0,4	0	2	10	1	Contractor	4	Solar panel	3						0					
Solar panel	1.2	2	1	Photovoltaic panel for converting sunlight into electricity	solar_panel.tscn	1,0	0	2	10	3	Electrician	4		2	10					0					
Tool library	2.8	4	4	TBD	arts_crafts_station.tscn	0,4	0	2	5	1	Contractor_	2		1						0					
Tree	2.5	2	2	Fruit-bearing trees or bushes	apple_tree2.tscn	0,0	1	2	2		Seeds	0		1						0	Seeds	Food			
Vegetables	0.5	1	1	Small garden bed for growing vegetables	vegetables.tscn	0,0	1	2	2		Seeds	0		1						0	Seeds,Water,Soil	Food		1	
Waste bin	0.5	2	2	TBD	donation_bin.tscn	0,4	0	1	5		Contractor	0		1						0		Waste,Seeds	10	1	
Donation box	0.5	2	2	TBD	donation_bin.tscn	0,4	0	1	5		Contractor	0		1						0		Materials			
Food stand	0.5	2	2	TBD	donation_bin.tscn	0,4	0	1	5		Contractor_	0		1						0	Food	Happiness	10	1	1"""
	var data = data_.split("\n")
	data = Array(data)
	for i in len(data):
		data[i] = data[i].split("\t")
		data[i] = Array(data[i])
		for j in [STRUCTURE_FIELDS.StructureWidth, STRUCTURE_FIELDS.StructureDepth, STRUCTURE_FIELDS.GroundBefore, STRUCTURE_FIELDS.GroundAfter, STRUCTURE_FIELDS.InitialHappiness, STRUCTURE_FIELDS.MaterialCost, STRUCTURE_FIELDS.DaysToComplete, STRUCTURE_FIELDS.Electricity, STRUCTURE_FIELDS.Water, STRUCTURE_FIELDS.Food, STRUCTURE_FIELDS.Waste, STRUCTURE_FIELDS.Soil, STRUCTURE_FIELDS.Happiness]:
			data[i][j] = int(data[i][j])
	return data
