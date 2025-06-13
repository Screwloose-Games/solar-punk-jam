class_name UpdateResourcesComponent
extends Node

@export var enabled: bool = true

@export var resources: Dictionary[ResourcesManager.ResourceType, int] = {
	ResourcesManager.ResourceType.ELECTRICITY: 0,
	ResourcesManager.ResourceType.WATER: 0,
	ResourcesManager.ResourceType.FOOD: 0,
	ResourcesManager.ResourceType.WASTE: 0,
	ResourcesManager.ResourceType.SOIL: 0,
	ResourcesManager.ResourceType.HAPPINESS: 0,
	ResourcesManager.ResourceType.MATERIALS: 0,
	ResourcesManager.ResourceType.SEEDS: 0,
}

@export var resource_storage_limits: Dictionary[ResourcesManager.ResourceType, int] = {
	ResourcesManager.ResourceType.ELECTRICITY: 20,
	ResourcesManager.ResourceType.WATER: 20,
}

func give_resources():
	for resource in resources:
		ResourcesManager.gain_resource_enum(resource, resources[resource])
		ResourcesManager.resource_storage_limits = resource_storage_limits
