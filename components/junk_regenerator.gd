extends Node

@export var num_junk_nodes_to_regenerate: int = 2

func _ready() -> void:
	EnvironmentManager.day_cycle_end.connect(_on_day_ended)

func _on_day_ended():
	regen_nodes()

func get_nodes_on_map() -> Array[CollectableNodeSpawner]:
	var nodes: Array[CollectableNodeSpawner]
	var new_nodes: Array = get_tree().get_nodes_in_group("CollectableNodeSpawner")
	nodes.append_array(new_nodes)
	return nodes

func regen_nodes():
	var nodes: Array[CollectableNodeSpawner] = get_collected_nodes()
	nodes.shuffle()
	var total_to_regen = min(num_junk_nodes_to_regenerate, nodes.size())
	for node in nodes.slice(0, total_to_regen):
		node.reset()

func get_collected_nodes() -> Array[CollectableNodeSpawner]:
	var all_nodes: Array[CollectableNodeSpawner] = get_nodes_on_map()
	var collected_nodes = all_nodes.filter(func(spawner: CollectableNodeSpawner): return spawner.is_collected)
	return collected_nodes
