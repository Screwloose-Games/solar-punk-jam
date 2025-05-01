extends Area3D
class_name InteractArea3D

@export var interact_action: String

var tracked_nodes: Array[InteractableArea3D] = []
var selected: InteractableArea3D = null

var player: Player


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
	if event.is_action_pressed("Interact"):
		if selected is InteractableArea3D:
			selected.interact(player)

func _get_property_list() -> Array:
	var props = []
	var actions = InputMap.get_actions()
	actions.sort()

	props.append({
		"name": "interact_action",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(actions),
		"usage": PROPERTY_USAGE_DEFAULT
	})
	return props
