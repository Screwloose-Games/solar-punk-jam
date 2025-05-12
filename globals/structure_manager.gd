extends Node

enum STRUCTURE_STATUS {
	JUST_CREATED, # just built or just planted on day 0
	NOT_READY, # if something is on a delay like growing vegetables this is the status
	READY, # ready to be collected or harvested
	EXPENDED # already collected or harvested, visually this is probably similar to JUST_CREATED or NOT_READY
}


class BuiltStructure:
	var surface: BuildableSurface
	var coords: Vector2i
	var structure: int
	var build_day: int
	var status: STRUCTURE_STATUS
	var ready_to_be_collected: Array
	var daily_resources_satisfied: bool
	var visual_instance: Node3D
	func _init(surface, coords, structure_id, build_day, status, visual_instance) -> void:
		self.surface = surface
		self.coords = coords
		self.structure = structure_id
		self.build_day = build_day
		self.status = status
		self.visual_instance = visual_instance
		self.daily_resources_satisfied = true
		self.ready_to_be_collected = []


@export_file("*.tsv") var tsv_file_path: String = "res://design/data/structures.tsv"

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

@export var environment_gain_per_structure_built: int = 3

var structure_data = []
var structure_name_to_idx_map = {}
var available_structures = []
var registered_structures = []


func _ready() -> void:
	structure_data = _get_structure_data()
	for idx in len(structure_data):
		structure_name_to_idx_map[structure_data[idx][STRUCTURE_FIELDS.StructureName]] = idx

	EnvironmentManager.connect("day_cycle_start", daily_collect_resources_from_structures)


func get_structure_name(index : int):
	return structure_data[index][STRUCTURE_FIELDS.StructureName]


func check_structure_requirements(idx):
	var material_cost = StructureManager.structure_data[idx][StructureManager.STRUCTURE_FIELDS.MaterialCost]
	var missing_requirements = []
	if material_cost > 0:
		if ResourcesManager.check_amount(ResourcesManager.ResourceType.MATERIALS, material_cost):
			# We have enough
			pass
		else:
			# We do not have enough
			missing_requirements.append("Materials")
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


func register_all_structures():
	prints("Unlocking all structures")
	for idx in len(structure_data):
		var struct_name = structure_data[idx][StructureManager.STRUCTURE_FIELDS.StructureName]
		register_structure(struct_name)
	UpdatedAvailableStructures.emit()


func build_structure(new_structure: BuiltStructure, skip_resource_consumption=false):
	if not skip_resource_consumption:
		if structure_data[new_structure.structure][StructureManager.STRUCTURE_FIELDS.MaterialCost] > 0:
			ResourcesManager.gain_resource_enum(ResourcesManager.ResourceType.MATERIALS, -structure_data[new_structure.structure][StructureManager.STRUCTURE_FIELDS.MaterialCost])
	var storage = StructureManager.structure_data[new_structure.structure][StructureManager.STRUCTURE_FIELDS.ElectricityStorage]
	if storage:
		ResourcesManager.add_storage_capacity(ResourcesManager.ResourceType.ELECTRICITY, storage)
	storage = StructureManager.structure_data[new_structure.structure][StructureManager.STRUCTURE_FIELDS.WaterStorage]
	if storage:
		ResourcesManager.add_storage_capacity(ResourcesManager.ResourceType.WATER, storage)
	visual_instance_update(new_structure)
	built_structures.append(new_structure)
	StructureBuilt.emit(new_structure)
	ResourcesManager.gain_resource_enum(ResourcesManager.ResourceType.ENVIRONMENT, environment_gain_per_structure_built)


func visual_instance_update(structure: BuiltStructure):
	if structure.visual_instance.has_method("set_structure_status"):
		structure.visual_instance.set_structure_status(structure.status)


func daily_collect_resources_from_structures():
	for structure in built_structures:
		if structure.status==STRUCTURE_STATUS.JUST_CREATED or structure.status==STRUCTURE_STATUS.EXPENDED:
			# TODO grow vegetables over many days as needed
			structure.status = STRUCTURE_STATUS.READY
			visual_instance_update(structure)

		var record = structure_data[structure.structure]
		# ["Electricity", "Water", "Food", "Waste", "Soil", "Happiness", "Materials", "Seeds"]
		# "Electricity, Water, Food, Waste, Soil, Happiness"

		# reset manual collection
		structure.ready_to_be_collected = []
		if structure_data[structure.structure][STRUCTURE_FIELDS.DailyManualCollection]:
			# Handle special structures separately
			match structure_data[structure.structure][STRUCTURE_FIELDS.StructureName]:
				"Waste bin":
					# convert environment food donation to waste and seeds
					for donated_item in ResourcesManager.deposited_resources:
						for donated_quantity in ResourcesManager.deposited_resources[donated_item]:
							for item in structure_data[structure.structure][STRUCTURE_FIELDS.DailyManualCollection].split(","):
								for count in structure_data[structure.structure][STRUCTURE_FIELDS.DailyManualCollectionMultiplier]:
									structure.ready_to_be_collected.append(item)
					# clear donated resources
					ResourcesManager.deposited_resources = {}
				"Rain barrel":
					var how_much_water_if_rains = int(structure_data[structure.structure][STRUCTURE_FIELDS.DailyManualCollectionMultiplier])
					if EnvironmentManager.environment_model.is_raining:
						ResourcesManager.gain_resource_enum(ResourcesManager.ResourceType.WATER, how_much_water_if_rains)
				_:
					if not structure_data[structure.structure][STRUCTURE_FIELDS.RequiresRefill] or structure_data[structure.structure][STRUCTURE_FIELDS.RequiresRefill] and structure.daily_resources_satisfied:
						for item in structure_data[structure.structure][STRUCTURE_FIELDS.DailyManualCollection].split(","):
							for count in structure_data[structure.structure][STRUCTURE_FIELDS.DailyManualCollectionMultiplier]:
								structure.ready_to_be_collected.append(item)



enum STRUCTURE_FIELDS {StructureName, StructureHeight, StructureWidth, StructureDepth, StructureDescription, StructureModel, StructureIcon, GroundBefore, GroundAfter, InitialHappiness, MaxStructures, UnlockedBy, MaterialCost, Requirements, DaysToComplete, Electricity, Water, Food, Waste, Soil, Happiness, BuildingConsumes, DailyManualCollection, DailyManualCollectionMultiplier, RequiresRefill, ConsumesAllInventory, ElectricityStorage, WaterStorage}


func _get_structure_data():
	var content = read_tsv()
	var data = content.split("\n")
	data = Array(data)
	data = data.filter(func(val): return val != "")
	for i in len(data):
		data[i] = data[i].split("\t")
		data[i] = Array(data[i])
		for j in [STRUCTURE_FIELDS.StructureWidth, STRUCTURE_FIELDS.StructureDepth, STRUCTURE_FIELDS.GroundBefore, STRUCTURE_FIELDS.GroundAfter, STRUCTURE_FIELDS.InitialHappiness, STRUCTURE_FIELDS.MaterialCost, STRUCTURE_FIELDS.DaysToComplete, STRUCTURE_FIELDS.Electricity, STRUCTURE_FIELDS.Water, STRUCTURE_FIELDS.Food, STRUCTURE_FIELDS.Waste, STRUCTURE_FIELDS.Soil, STRUCTURE_FIELDS.Happiness, STRUCTURE_FIELDS.ElectricityStorage, STRUCTURE_FIELDS.WaterStorage]:
			data[i][j] = int(data[i][j])
	return data

func read_tsv() -> String:
	# this file is a copy paste of the CSV exported from Notion
	# Name,priority,height,width,depth,description,model filename,Icon,Art Status,Electricity Generation/Use,Water Generation/Use,Food Generation/Use,Happiness Generation,Electricity Stroage,Water Storage,Food Storage,Cost
	var file := FileAccess.open(tsv_file_path, FileAccess.READ)
	if file:
		var content := file.get_as_text()
		file.close()
		return content
	else:
		push_error("Failed to open TSV file at: " + tsv_file_path)
		return ""
