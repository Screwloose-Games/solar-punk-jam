extends Node

@export var deployed: bool = true

@onready var animation_player: AnimationPlayer = $"../sm_solar_panel/AnimationPlayer"
@onready var interactable_area_3d: InteractableArea3D = %InteractableArea3D

func _ready() -> void:
	animation_player.play("Deploy")
	interactable_area_3d.interacted.connect(_on_interacted)

func _on_interacted():
	deployed = !deployed
