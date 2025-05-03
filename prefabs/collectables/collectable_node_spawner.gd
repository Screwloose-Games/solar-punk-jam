class_name CollectableNodeSpawner
extends Node3D

@onready var collectable: Collectable = find_child_collectable()

var is_collected: bool = true

func _ready() -> void:
	if collectable:
		collectable.collected.connect(_on_collectable_collected)
	else:
		push_warning("Collectable node not found! Please add a child node of type 'Collectable'.")

func _on_collectable_collected():
	despawn()

func despawn():
	is_collected = true
	if collectable:
		collectable.hide()
		collectable.process_mode = Node.PROCESS_MODE_DISABLED

func reset():
	is_collected = false
	if collectable:
		collectable.show()
		collectable.process_mode = Node.PROCESS_MODE_INHERIT

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if find_child_collectable() == null:
		warnings.append("This node requires a child of type 'Collectable'.")
	return warnings

func find_child_collectable() -> Collectable:
	for child in get_children():
		if child is Collectable:
			return child
	return null
