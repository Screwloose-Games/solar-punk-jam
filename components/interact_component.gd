@tool
class_name InteractArea3D
extends Area3D

signal selected_updated(current_selected: InteractableArea3D)
signal started_interacting
signal stopped_interacting

var tracked_nodes: Array[InteractableArea3D] = []
var selected: InteractableArea3D = null:
	set(val):
		selected = val
		selected_updated.emit(selected)

var player: Player

var interact_action: StringName
var is_interacting: bool = false:
	set(val):
		is_interacting = val
		if is_interacting:
			started_interacting.emit()
		else:
			stopped_interacting.emit()
			if selected:
				selected.stop_interacting()

func _on_stopped_interacting(interactable: InteractableArea3D):
	is_interacting = false
	interactable.stopped_interacting.disconnect(_on_stopped_interacting)

func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	if not player:
		player = owner


func _on_area_entered(area: Area3D):
	if area is InteractableArea3D:
		tracked_nodes.append(area)
		select_closest()


func select_closest():
	for tracked in tracked_nodes:
		tracked.unselect()
	if tracked_nodes.size() > 0:
		tracked_nodes[0].select()
		selected = tracked_nodes[0]


func _on_area_exited(area: Area3D):
	if area is InteractableArea3D:
		area.unselect()
		tracked_nodes.erase(area)
		if tracked_nodes.size() > 0:
			select_closest()
		else:
			selected = null

func _unhandled_input(event):
	if event.is_action_pressed(interact_action):
		handle_interact()

func handle_interact():
	if owner.is_interacting and selected and selected.toggleable:
		is_interacting = false
	if owner.should_ignore_interact:
		return
	if selected is InteractableArea3D:
		selected.interact(player)
		if !selected.stopped_interacting.is_connected(_on_stopped_interacting.bind(selected)):
			selected.stopped_interacting.connect(_on_stopped_interacting.bind(selected))
		if !selected.tree_exited.is_connected(_on_stopped_interacting.bind(selected)):
			selected.tree_exited.connect(_on_stopped_interacting.bind(selected))
		is_interacting = true

func get_actions():
	var proj_file := ConfigFile.new()
	if proj_file.load("res://project.godot"):
		printerr("Failed to open \"project.godot\"! Custom input actions will not work on editor view!")
		return
	if proj_file.has_section("input"):
		return proj_file.get_section_keys("input")

func _get_property_list() -> Array:
	var props = []
	var actions = get_actions()
	actions.sort()

	props.append({
		"name": "interact_action",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(actions),
		"usage": PROPERTY_USAGE_DEFAULT
	})
	return props
