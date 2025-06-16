extends Node

signal updated_available_structures
signal buildable_structure_selected(idx: int)
signal structure_built(s: BuiltStructure)
signal built_structure(s_name: String)

enum StructureStatus { JUST_CREATED, NOT_READY, READY, EXPENDED }

enum StructureFields {
	STRUCTURE_NAME,
	STRUCTURE_HEIGHT,
	STRUCTURE_WIDTH,
	STRUCTURE_DEPTH,
	STRUCTURE_DESCRIPTION,
	STRUCTURE_MODEL,
	STRUCTURE_ICON,
	GROUND_BEFORE,
	GROUND_AFTER,
	INITIAL_HAPPINESS,
	MAX_STRUCTURES,
	UNLOCKED_BY,
	MATERIAL_COST,
	REQUIREMENTS,
	DAYS_TO_COMPLETE,
	ELECTRICITY,
	WATER,
	FOOD,
	WASTE,
	SOIL,
	HAPPINESS,
	BUILDING_CONSUMES,
	DAILY_MANUAL_COLLECTION,
	DAILY_MANUAL_COLLECTION_MULTIPLIER,
	REQUIRES_REFILL,
	CONSUMES_ALL_INVENTORY,
	ELECTRICITY_STORAGE,
	WATER_STORAGE
}

const BUILDABLE_EMPTY_SPACE = Vector2i(2, 7)
const BUILDABLE_RAISED_BED_SPACE = Vector2i(4, 7)
const OCCUPIED_SPACE = Vector2i(0, 7)
const VALID_TILE_TYPES = [BUILDABLE_EMPTY_SPACE, BUILDABLE_RAISED_BED_SPACE, OCCUPIED_SPACE]

class BuiltStructure:
	var surface: BuildableSurface
	var coords: Vector2i
	var structure: int
	var build_day: int
	var status: StructureStatus
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
@export var environment_gain_per_structure_built: int = 3

var built_structures: Array[BuiltStructure] = []
var current_active_surface = null
var structure_data = []
var structure_name_to_idx_map = {}
var available_structures = []
var registered_structures = []


func set_active_surface(surface):
	prints("set_active_surface", surface, surface.name, surface.is_active)
	if surface == current_active_surface:
		return
	if current_active_surface:
		current_active_surface.is_active = false
	current_active_surface = surface

func _ready() -> void:
	structure_data = _get_structure_data()
	for idx in len(structure_data):
		structure_name_to_idx_map[structure_data[idx][StructureFields.STRUCTURE_NAME]] = idx

	EnvironmentManager.connect("day_cycle_start", daily_collect_resources_from_structures)


func get_structure_name(index: int):
	return structure_data[index][StructureFields.STRUCTURE_NAME]


func check_structure_requirements(idx):
	var material_cost = StructureManager.structure_data[idx][
		StructureManager.StructureFields.MATERIAL_COST
	]
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


func register_structure(struct_name: String):
	print("Unlocking structure: %s" % struct_name)
	if struct_name in registered_structures:
		return
	registered_structures.append(struct_name)
	for idx in len(structure_data):
		if structure_data[idx][StructureManager.StructureFields.STRUCTURE_NAME] == struct_name:
			available_structures.append(idx)
	updated_available_structures.emit()


func register_character_structures(character: String):
	prints("Unlocking structures from", character)
	for idx in len(structure_data):
		if structure_data[idx][StructureManager.StructureFields.UNLOCKED_BY] == character:
			var struct_name = structure_data[idx][StructureManager.StructureFields.STRUCTURE_NAME]
			register_structure(struct_name)
	updated_available_structures.emit()


func register_all_structures():
	prints("Unlocking all structures")
	for idx in len(structure_data):
		var struct_name = structure_data[idx][StructureManager.StructureFields.STRUCTURE_NAME]
		register_structure(struct_name)
	updated_available_structures.emit()


func build_structure(new_structure: BuiltStructure, skip_resource_consumption = false):
	if not skip_resource_consumption:
		if (
			structure_data[new_structure.structure][StructureManager.StructureFields.MATERIAL_COST]
			> 0
		):
			ResourcesManager.gain_resource_enum(
				ResourcesManager.ResourceType.MATERIALS,
				-structure_data[new_structure.structure][
					StructureManager.StructureFields.MATERIAL_COST
				]
			)
	var storage = StructureManager.structure_data[new_structure.structure][
		StructureManager.StructureFields.ELECTRICITY_STORAGE
	]
	if storage:
		ResourcesManager.add_storage_capacity(ResourcesManager.ResourceType.ELECTRICITY, storage)
	storage = StructureManager.structure_data[new_structure.structure][
		StructureManager.StructureFields.WATER_STORAGE
	]
	if storage:
		ResourcesManager.add_storage_capacity(ResourcesManager.ResourceType.WATER, storage)
	visual_instance_update(new_structure)
	built_structures.append(new_structure)
	structure_built.emit(new_structure)
	built_structure.emit(get_structure_name(new_structure.structure))
	ResourcesManager.gain_resource_enum(
		ResourcesManager.ResourceType.ENVIRONMENT, environment_gain_per_structure_built
	)


func visual_instance_update(structure: BuiltStructure):
	if structure.visual_instance.has_method("set_StructureStatus"):
		structure.visual_instance.set_StructureStatus(structure.status)


func daily_collect_resources_from_structures():
	for structure in built_structures:
		if (
			structure.status == StructureStatus.JUST_CREATED
			or structure.status == StructureStatus.EXPENDED
		):
			# TODO grow vegetables over many days as needed
			structure.status = StructureStatus.READY
			visual_instance_update(structure)

		var record = structure_data[structure.structure]
		# ["Electricity", "Water", "Food", "Waste", "Soil", "Happiness", "Materials", "Seeds"]
		# "Electricity, Water, Food, Waste, Soil, Happiness"

		# reset manual collection
		structure.ready_to_be_collected = []
		if structure_data[structure.structure][StructureFields.DAILY_MANUAL_COLLECTION]:
			# Handle special structures separately
			match structure_data[structure.structure][StructureFields.STRUCTURE_NAME]:
				"Waste bin":
					# convert environment food donation to waste and seeds
					for donated_item in ResourcesManager.deposited_resources:
						for donated_quantity in ResourcesManager.deposited_resources[donated_item]:
							for item in (
								structure_data[structure.structure][
									StructureFields.DAILY_MANUAL_COLLECTION
								]
								. split(",")
							):
								for count in structure_data[structure.structure][
									StructureFields.DAILY_MANUAL_COLLECTION
								]:
									structure.ready_to_be_collected.append(item)
					# clear donated resources
					ResourcesManager.deposited_resources = {}
				"Rain barrel":
					var how_much_water_if_rains = int(
						structure_data[structure.structure][
							StructureFields.DAILY_MANUAL_COLLECTION
						]
					)
					if EnvironmentManager.environment_model.is_raining:
						ResourcesManager.gain_resource_enum(
							ResourcesManager.ResourceType.WATER, how_much_water_if_rains
						)
				_:
					if (
						not structure_data[structure.structure][StructureFields.REQUIRES_REFILL]
						or (
							structure_data[structure.structure][StructureFields.REQUIRES_REFILL]
							and structure.daily_resources_satisfied
						)
					):
						for item in (
							structure_data[structure.structure][
								StructureFields.DAILY_MANUAL_COLLECTION
							]
							. split(",")
						):
							for count in structure_data[structure.structure][
								StructureFields.DAILY_MANUAL_COLLECTION
							]:
								structure.ready_to_be_collected.append(item)

func _get_structure_data():
	var content = read_tsv()
	var data = content.split("\n")
	data = Array(data)
	data = data.filter(func(val): return val != "")
	for i in len(data):
		data[i] = data[i].split("\t")
		data[i] = Array(data[i])
		for j in [
			StructureFields.STRUCTURE_WIDTH,
			StructureFields.STRUCTURE_DEPTH,
			StructureFields.GROUND_BEFORE,
			StructureFields.GROUND_AFTER,
			StructureFields.INITIAL_HAPPINESS,
			StructureFields.MATERIAL_COST,
			StructureFields.DAYS_TO_COMPLETE,
			StructureFields.ELECTRICITY,
			StructureFields.WATER,
			StructureFields.FOOD,
			StructureFields.WASTE,
			StructureFields.SOIL,
			StructureFields.HAPPINESS,
			StructureFields.ELECTRICITY_STORAGE,
			StructureFields.WATER_STORAGE
		]:
			data[i][j] = int(data[i][j])
	return data

func read_tsv() -> String:
	# this file is a copy paste of the CSV exported from Notion
	# Name,priority,height,width,depth,description,model filename,Icon,Art Status,\
	# Electricity Generation/Use,Water Generation/Use,Food Generation/Use,Happiness\
	# Generation,Electricity Storage,Water Storage,Food Storage,Cost
	var file := FileAccess.open(tsv_file_path, FileAccess.READ)
	if file:
		var content := file.get_as_text()
		file.close()
		return content
	push_error("Failed to open TSV file at: " + tsv_file_path)
	return ""
