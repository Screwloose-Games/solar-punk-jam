extends Node
#class_name ResourcesManager

signal UpdatedAvailableResources

enum ResourceType {
	ELECTRICITY,
	WATER,
	FOOD,
	WASTE,
	SOIL,
	HAPPINESS,
	MATERIALS,
	SEEDS,
	ENVIRONMENT,
	COMMUNITY,
}

const RESOURCE_TYPE_NAMES: Dictionary[ResourceType, String] = {
	ResourceType.ELECTRICITY: "Electricity",
	ResourceType.WATER: "Water",
	ResourceType.FOOD: "Food",
	ResourceType.WASTE: "Waste",
	ResourceType.SOIL: "Soil",
	ResourceType.HAPPINESS: "Happiness",
	ResourceType.MATERIALS: "Materials",
	ResourceType.SEEDS: "Seeds",
	ResourceType.ENVIRONMENT: "Environment",
	ResourceType.COMMUNITY: "Community"
}

var resource_strings: Array[String] = RESOURCE_TYPE_NAMES.values()
var resource_types: Array[ResourceType] = RESOURCE_TYPE_NAMES.keys()
var resources = RESOURCE_TYPE_NAMES.values()

func get_resource_by_name(resource_name: String):
	var index = resource_strings.find(resource_name)
	return resource_types[index]

var resource_storage_limits = {
	"Electricity": 0,
	"Water": 0,
}

var starting_resources: Dictionary = {
	"Happiness": 10
}

var current_resources = {}
var daily_resources = {}
var deposited_resources = {}

func _ready() -> void:
	print("resources: ", ResourceType.values())
	initialize()
	GlobalSignalBus.world_unloaded.connect(_on_world_unloaded)

func initialize():
	for resource in resources:
		current_resources[resource] = 0
		daily_resources[resource] = 0
	current_resources.merge(starting_resources, true)

func _on_world_unloaded():
	reset()

func reset():
	initialize()

func add_storage_capacity(resource: String, amount: int) -> void:
	if not resource_storage_limits.has(resource):
		push_warning("Trying to add storage for an unknown resource: %s" % resource)
		return
	resource_storage_limits[resource] += amount

func set_storage_capacity(resource: String, amount: int) -> void:
	if not resource_storage_limits.has(resource):
		push_warning("Trying to set storage for an unknown resource: %s" % resource)
		return
	resource_storage_limits[resource] = amount

func get_storage_capacity(resource: String) -> int:
	if not resource_storage_limits.has(resource):
		push_warning("Trying to get storage for an unknown resource: %s" % resource)
		return 0
	return resource_storage_limits[resource]

func gain_resource(resource: String, quantity: int):
	if resource in current_resources:
		current_resources[resource] += quantity
	else:
		current_resources[resource] = quantity
		
		
	if resource in daily_resources:
		daily_resources[resource] += quantity
	else:
		daily_resources[resource] = quantity
		
		

	if resource in resource_storage_limits:
		if current_resources[resource] > resource_storage_limits[resource]:
			prints("We cannot store all of this resource, discarding some")
			current_resources[resource] = resource_storage_limits[resource]
		if daily_resources[resource] > resource_storage_limits[resource]:
			daily_resources[resource] = resource_storage_limits[resource]

	UpdatedAvailableResources.emit()

func gain_resources(new_resources: Dictionary[String, int]):
	for resource in new_resources:
		gain_resource(resource, new_resources[resource])
	return true

func spend_resource(resource: String, quantity: int):
	if resource in current_resources:
		current_resources[resource] -= quantity
		if current_resources[resource] < 0:
			current_resources[resource] = 0
	else:
		current_resources[resource] = 0
	UpdatedAvailableResources.emit()

func spend_resources(new_resources: Dictionary[String, int]):
	for resource in new_resources:
		spend_resource(resource, new_resources[resource])
	return true

func deposit_resource(resource: String, quantity: int):
	prints("Depositing", resource, quantity, current_resources)
	if resource in current_resources:
		deposited_resources[resource] += quantity
	else:
		deposited_resources[resource] = quantity
	UpdatedAvailableResources.emit()

func check_amount(resource: String, quantity: int):
	return has_at_least(resource, quantity)
		
func has_at_least(resource: String, quantity: int):
	if resource in current_resources:
		return current_resources[resource] >= quantity
	else:
		return false

func has_enough(required_resources: Dictionary[String, int]):
	for resource in required_resources:
		if resource in current_resources:
			if current_resources[resource] < required_resources[resource]:
				return false
	return true

func get_resource_count(resource: String):
	if resource in current_resources:
		return current_resources[resource]
	return 0
