extends Area3D
class_name InteractableArea3D

@export var label_text: String = "Interact":
	set(val):
		label_text = val
		if interactable_label_3d:
			interactable_label_3d.text = label_text

signal interacted(player: Player)
signal stopped_interacting
signal selected
signal unselected

var is_interacting: bool = false:
	set(val):
		if val == is_interacting:
			return
		is_interacting = val
		if is_interacting:
			pass
		else:
			stopped_interacting.emit()

var is_selected = false:
	set = set_selected

var disabled := false:
	set(val):
		disabled = val
		monitoring = !val
		monitorable = !val

@onready var interactable_label_3d: Label3D = %InteractableLabel3D

func _ready():
	interactable_label_3d.text = label_text
	interactable_label_3d.visible = false

func select():
	is_selected = true
	interactable_label_3d.visible = true
	selected.emit()

func _exit_tree() -> void:
	stop_interacting()

func unselect():
	is_selected = false
	interactable_label_3d.visible = false
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
