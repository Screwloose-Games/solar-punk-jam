extends GridMap

var grid = []



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var used_cells: Array[Vector3i]= get_used_cells() 
	for cell in used_cells:
		pass
		# make the cell "receivable" of placing an item.

	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#var tile = local_to_map() 
	#get_viewport()
	pass

func get_hovered_grid_square():
	pass
