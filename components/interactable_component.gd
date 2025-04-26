extends Area3D
class_name InteractableArea3D

signal interacted(player: Player)
signal stopped_interacting
signal selected
signal unselected

var is_interacting: bool = false
var is_selected = false:
	set = set_selected

var disabled := false:
	set(val):
		disabled = val
		monitoring = !val
		monitorable = !val


func _ready():
	stopped_interacting.connect(_on_stopped_interacting)


func _on_stopped_interacting():
	is_interacting = false


func select():
	is_selected = true
	selected.emit()


func unselect():
	is_selected = false
	unselected.emit()


func set_selected(val: bool):
	is_selected = val

func stop_interacting():
	is_interacting = false

func interact(player: Player):
	if is_interacting:
		return
	interacted.emit(player)
	print("interacted")
	is_interacting = true
