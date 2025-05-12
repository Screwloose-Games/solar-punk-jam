class_name Collectable
extends Node3D

signal collected

#@export var collected_resource: ResourceTracker.ResourceType
@export var collected_resource: ResourcesManager.ResourceType = ResourcesManager.ResourceType.MATERIALS
@export var count: int
@export var environment_gain: int = 1

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D

func _ready():
	interactable_area_3d.interacted.connect(_on_interacted)

func _on_interacted(_player: Player):
	collect()
	interactable_area_3d.stop_interacting()

func collect():
	ResourcesManager.gain_resource_enum(collected_resource, count)
	ResourcesManager.gain_resource_enum(ResourcesManager.ResourceType.ENVIRONMENT, environment_gain)
	collected.emit()
	GlobalSignalBus.scrap_collected.emit()
