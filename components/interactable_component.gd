extends Area3D
class_name InteractableArea3D

signal interacted(player)
signal stopped_interacting

var is_interacting: bool = false
var selected = false:
	set = set_selected

var disabled := false:
	set(val):
		disabled = val
		monitoring = !val
		monitorable = !val
		#if disabled:
		#selected = false


func _ready():
	stopped_interacting.connect(_on_stopped_interacting)


func _on_stopped_interacting():
	is_interacting = false


func select():
	selected = true


func unselect():
	selected = false


func set_selected(val: bool):
	selected = val


func interact(player):
	if is_interacting:
		return
	interacted.emit(player)
	print("interacted")
	is_interacting = true
