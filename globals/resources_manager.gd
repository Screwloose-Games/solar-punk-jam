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

func get_resource_by_name(resource_name: String) -> ResourceType:
	var index = resource_strings.find(resource_name)
	return resource_types[index]

var resource_storage_limits: Dictionary[ResourceType, int] = {
	ResourceType.ELECTRICITY: 0,
	ResourceType.WATER: 0,
}

var starting_resources: Dictionary = {
	"Happiness": 10
}

var current_resources: Dictionary[String, int] = {}
var daily_resources: Dictionary[String, int] = {}
var deposited_resources: Dictionary[String, int] = {}

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

func add_storage_capacity(resource: ResourceType, amount: int) -> void:
	if not resource_storage_limits.has(resource):
		push_warning("Trying to add storage for an unknown resource: %s" % resource)
		return
	resource_storage_limits[resource] += amount

func set_storage_capacity(resource: ResourceType, amount: int) -> void:
	if not resource_storage_limits.has(resource):
		push_warning("Trying to set storage for an unknown resource: %s" % resource)
		return
	resource_storage_limits[resource] = amount

func get_storage_capacity(resource: ResourceType) -> int:
	if not resource_storage_limits.has(resource):
		push_warning("Trying to get storage for an unknown resource: %s" % resource)
		return 0
	return resource_storage_limits[resource]

func gain_resource_str(resource: String, quantity: int):
	var resource_enum: ResourceType = get_resource_by_name(resource)
	gain_resource_enum(resource_enum, quantity)

func gain_resource_enum(resource: ResourceType, quantity: int):
	var resource_str = RESOURCE_TYPE_NAMES[resource]
	if resource_str in current_resources:
		current_resources[resource_str] += quantity
	else:
		current_resources[resource_str] = quantity
	if resource_str in daily_resources:
		daily_resources[resource_str] += quantity
	else:
		daily_resources[resource_str] = quantity

	if resource in resource_storage_limits:
		if current_resources[resource_str] > resource_storage_limits[resource]:
			prints("We cannot store all of this resource, discarding some")
			current_resources[resource_str] = resource_storage_limits[resource]
		if daily_resources[resource_str] > resource_storage_limits[resource]:
			daily_resources[resource_str] = resource_storage_limits[resource]

	UpdatedAvailableResources.emit()

func gain_resources_enum(new_resources: Dictionary[ResourceType, int]):
	for resource in new_resources:
		gain_resource_enum(resource, new_resources[resource])
	return true

func spend_resource(resource: ResourceType, quantity: int):
	var resource_str: String = RESOURCE_TYPE_NAMES[resource]
	if resource in current_resources:
		current_resources[resource_str] -= quantity
		if current_resources[resource_str] < 0:
			current_resources[resource_str] = 0
	else:
		current_resources[resource_str] = 0
	UpdatedAvailableResources.emit()

func spend_resources(new_resources: Dictionary[ResourceType, int]):
	for resource in new_resources:
		spend_resource(resource, new_resources[resource])
	return true

func deposit_resource(resource: ResourceType, quantity: int):
	prints("Depositing", resource, quantity, current_resources)
	var resource_str: String = RESOURCE_TYPE_NAMES[resource]
	if resource in current_resources:
		deposited_resources[resource_str] += quantity
	else:
		deposited_resources[resource_str] = quantity
	UpdatedAvailableResources.emit()

func check_amount(resource: ResourceType, quantity: int):
	return has_at_least(resource, quantity)

func has_at_least(resource: ResourceType, quantity: int):
	var resource_str: String = RESOURCE_TYPE_NAMES[resource]
	if resource_str in current_resources:
		return current_resources[resource_str] >= quantity
	else:
		return false

func has_enough(required_resources: Dictionary[ResourceType, int]):
	for resource in required_resources:
		var resource_str: String = RESOURCE_TYPE_NAMES[resource]
		if resource_str in current_resources:
			if current_resources[resource_str] < required_resources[resource]:
				return false
	return true

func get_resource_count(resource: ResourceType):
	if resource in current_resources:
		var resource_str: String = RESOURCE_TYPE_NAMES[resource]
		return current_resources[resource_str]
	return 0
