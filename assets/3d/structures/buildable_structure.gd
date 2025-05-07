class_name PlaceableStructure
extends Node3D

const STRUCTURE_MAP = {
	5 : "built_compost",
	6 : "built_hygiene",
	11 : "built_rain_barrel",
	12 : "built_raised_bed",
	13 : "built_vplanter",
	20 : "built_donation"
}


signal interacted

@export var structure_id: int = 0

@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D

func _ready() -> void:
	interactable_area_3d.interacted.connect(_on_interacted)

func _on_interacted(player: Player):
	GlobalSignalBus.structure_interacted.emit()
	interacted.emit()
