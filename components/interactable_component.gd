class_name InteractableArea3D
extends Area3D

signal interacted(player: Player)
signal stopped_interacting
signal selected
signal unselected

@export var interactable_id : String = ""
@export var label_text: String = "Interact":
	set(val):
		label_text = val
		if interactable_label_3d:
			interactable_label_3d.text = label_text
@export var show_label: bool = false
## Should this component allow toggling pressing interact again?
@export var toggleable: bool = false

var is_selected : bool = false
var is_interacting: bool = false:
	set(val):
		if val == is_interacting:
			return
		is_interacting = val
		if is_interacting:
			pass
		else:
			stopped_interacting.emit.call_deferred()
var disabled := false:
	set(val):
		disabled = val
		monitoring = !val
		monitorable = !val

@onready var interactable_label_3d: Label3D = %InteractableLabel3D


func _ready():
	interactable_label_3d.text = label_text
	interactable_label_3d.visible = false


func _exit_tree() -> void:
	stop_interacting()


func select():
	is_selected = true
	if show_label:
		interactable_label_3d.visible = true
	selected.emit()


func unselect():
	is_selected = false
	interactable_label_3d.visible = false
	unselected.emit()


func stop_interacting():
	is_interacting = false


func interact(player: Player):
	if is_interacting:
		return
	is_interacting = true
	interacted.emit(player)
	GlobalSignalBus.object_interacted.emit(interactable_id)
	print("Interacted: %s" % interactable_id)
