class_name PlaceableStructure
extends Node3D

signal interacted

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D

func _ready() -> void:
	interactable_area_3d.interacted.connect(_on_interacted)

func _on_interacted(player: Player):
	interacted.emit()
