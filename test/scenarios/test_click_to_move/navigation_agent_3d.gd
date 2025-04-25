extends NavigationAgent3D

@onready var actor: CharacterBody3D = owner


func _ready() -> void:
	link_reached.connect(_on_link_reached)


func _on_link_reached(details: Dictionary):
	var link_entry_position = details.get("link_entry_position")
	var link_exit_position = details.get("link_exit_position")
	var link_owner = details.get("owner")

	actor.global_position = link_exit_position
	print(details.get("owner"))
