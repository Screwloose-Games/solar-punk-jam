class_name Collectable
extends Node3D

signal collected

#@export var collected_resource: ResourceTracker.ResourceType
@export var collected_resource: String
@export var count: int

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D

func _ready():
	interactable_area_3d.interacted.connect(_on_interacted)

func _on_interacted(_player: Player):
	collect()
	interactable_area_3d.stop_interacting()

func collect():
	EnvironmentManager.gain_resource(collected_resource, count)
	collected.emit()
