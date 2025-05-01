extends Node

@onready var buildable_surface: BuildableSurface = %BuildableSurface
@onready var buildable_area_3d: InteractableArea3D = %BuildableArea3D

func _ready() -> void:
	buildable_area_3d.interacted.connect(_on_interacted)
	buildable_area_3d.stopped_interacting.connect(_on_stopped_interacting)

func _on_interacted(actor: Player):
	buildable_surface.is_active = true

func _on_stopped_interacting():
	buildable_surface.is_active = false
