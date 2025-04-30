extends Node

@export var resources: Dictionary[String, int] = {
	"Electricity": 0,
	"Water": 0,
	"Food": 0,
	"Waste": 0,
	"Soil": 0,
	"Happiness": 0,
	"Materials": 0,
	"Seeds": 0,
}

func _ready() -> void:
	await owner.ready
	give_resources()

func give_resources():
	for resource in resources:
		EnvironmentManager.gain_resource(resource, resources[resource])
