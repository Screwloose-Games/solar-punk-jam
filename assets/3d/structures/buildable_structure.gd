class_name PlaceableStructure
extends Node3D

signal interacted

@export_enum("Compost bin", "Picnic Table", "Raised bed", "Rain barrel", "Vertical garden",
"Recycling station", "Solar panel", "Waste bin", "Donation box",
"Food stand") var structure_name: String

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D


func _ready() -> void:
	interactable_area_3d.interacted.connect(_on_interacted)


func _on_interacted(_player: Player):
	if structure_name:
		print("Interacted with: ", structure_name)
		GlobalSignalBus.structure_interacted.emit(structure_name)
	interacted.emit()
