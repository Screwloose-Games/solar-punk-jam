extends Area3D
class_name InteractArea3D

var tracked_nodes: Array[Node3D] = []
var selected: Node3D = null

var player


func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	if not player:
		player = owner


func _on_area_entered(area: Area3D):
	if area is InteractableArea3D:
		for tracked in tracked_nodes:
			tracked.unselect()
		tracked_nodes.append(area)
		area.select()
		selected = area


func select_closest():
	for tracked in tracked_nodes:
		tracked.unselect()
	if tracked_nodes.size() > 0:
		tracked_nodes[0].select()
		selected = tracked_nodes[0]


func _on_area_exited(area: Area3D):
	if area.is_in_group("Interactable"):
		area.unselect()
		tracked_nodes.erase(area)
		if tracked_nodes.size() > 0:
			selected = tracked_nodes[0]
			selected.select()
		else:
			selected = null


func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		if selected:
			selected.interact(player)
