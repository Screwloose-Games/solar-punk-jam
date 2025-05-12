class_name UpdateResourcesComponent
extends Node

@export var enabled: bool = true

@export var resources = {
	"Electricity": 0,
	"Water": 0,
	"Food": 0,
	"Waste": 0,
	"Soil": 0,
	"Happiness": 0,
	"Materials": 0,
	"Seeds": 0,
}

@export var resource_storage_limits = {
	"Electricity": 0,
	"Water": 0,
}

func give_resources():
	for resource in resources:
		ResourcesManager.gain_resource(resource, resources[resource])
		ResourcesManager.resource_storage_limits = resource_storage_limits
