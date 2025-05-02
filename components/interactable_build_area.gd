extends Node

@export var buildable_surface: BuildableSurface = owner
@onready var interactable_build_area: InteractableArea3D = %InteractableBuildableArea

func _ready() -> void:
	if not buildable_surface:
		buildable_surface = owner
	interactable_build_area.interacted.connect(_on_interacted)
	interactable_build_area.stopped_interacting.connect(_on_stopped_interacting)

func _on_interacted(actor: Player):
	StructureManager.set_active_surface(owner)

func _on_stopped_interacting():
	buildable_surface.is_active = false
