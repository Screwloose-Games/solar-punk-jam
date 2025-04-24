extends Node3D

@onready var surface = $"../CanvasLayer/Node2D/TileMap" as TileMap

var walkable = []
func update_walkable_coords():
	walkable = []
	for coords in surface.get_used_cells(0):
		match surface.get_cell_atlas_coords(0, coords):
			Vector2i(2,7):
				# regular rooftop ground
				walkable.append(coords)
			Vector2i(3,7):
				# teleporter
				# don't let NPCs go into teleporters
				pass
				#walkable.append(coords)
	return walkable

func get_random_walkable_coord() -> Vector2i:
	walkable.shuffle()
	return walkable[0]

var npcs = []
var npc_positions = {}
func _ready() -> void:
	update_walkable_coords()
	for i in get_children():
		if i is CapybaraCharacter:
			npcs.append(i)
			send_npc_around(i)
	var tween = create_tween()
	tween.set_loops()
	tween.tween_interval(2.0)
	tween.tween_callback(send_npcs_around)
	
var interval = IntervalTweener
func send_npcs_around():
	send_npc_around(npcs.pick_random())
	
func send_npc_around(npc: CapybaraCharacter):
	var target = get_random_walkable_coord()
	npc_positions[npc] = target
	npc.move_to_position(Vector3(target.x, -1, target.y))

func move_out_of_the_way():
	update_walkable_coords()
	for npc in npc_positions.keys():
		if npc_positions[npc] not in walkable:
			send_npc_around(npc)
