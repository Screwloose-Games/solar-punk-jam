@tool
extends EditorScript

class_name CsvStructureSceneBuilder

const BASE_PATH := "res://assets/3d/structures"

func _run():
	var csv_path = "res://design/data/structures.csv"
	process_csv(csv_path)

func process_csv(csv_file_path: String) -> void:
	print("Ran")
	var file = FileAccess.open(csv_file_path, FileAccess.READ)
	if not file:
		print("Could not open CSV file: %s" % csv_file_path)
		push_error("Could not open CSV file: %s" % csv_file_path)
		return

	var header = file.get_line().strip_edges().split(",")
	print(header)
	while not file.eof_reached():
		var row = file.get_line().strip_edges().split(",")
		if row.size() < 6:
			print("not enough data in the row")
			print(row)
			continue

		var item_name: String = row[0]
		var height := row[1].to_float()
		var width := row[2].to_float()
		var depth := row[3].to_float()
		var description: String = row[4]
		var filename := row[5].get_basename()  # remove extension if present

		var structure_path := "%s/%s" % [BASE_PATH, filename]
		var scene_path := "%s/%s.tscn" % [structure_path, filename]

		if not DirAccess.dir_exists_absolute(structure_path):
			print("making directory: ", structure_path)
			DirAccess.make_dir_recursive_absolute(structure_path)

		if not FileAccess.file_exists(scene_path):
			print("making scene: ", scene_path)
			create_structure_scene(scene_path, item_name, Vector3(width, height, depth))

	file.close()

func to_pascal_case(name: String) -> String:
	var regex = RegEx.new()
	regex.compile("\\W+|_+")
	var parts: Array[RegExMatch] = regex.search_all(name)
	#var parts = name.split(regex.compile("\\W+|_+"), true)
	var result = ""
	for part in parts:
		if part.get_string() != "":
			result += part.substr(0, 1).to_upper() + part.substr(1).to_lower()
	return result

func make_owner_of_all_descendants(root: Node, owner: Node = root):
	for child in root.get_children():
		child.set_owner(owner)
		make_owner_of_all_descendants(child, owner)

func add_named_child(parent: Node, child: Node, name_unique_in_scene: bool = false):
	var cls_name
	var script = child.get_script()
	if is_instance_valid(script):
		cls_name = script.get_global_name()
	else:
		cls_name = child.get_class()
	if name_unique_in_scene:
		child.set_unique_name_in_owner(true)
	parent.add_child(child)
	child.name = cls_name
	if child.name != cls_name:
		push_error("Name is not ", "\"", cls_name, "\".",  " Is this name already used?")

func export_as_scene(root_node: Node, filepath: String = "res://exported_scene.tscn"):
	make_owner_of_all_descendants(root_node)

	var packed_scene = PackedScene.new()
	if packed_scene.pack(root_node) == OK:
		if ResourceSaver.save(packed_scene, filepath) == OK:
			print("Scene saved successfully to", filepath)
		else:
			push_error("Failed to save the scene to " + filepath)
	else:
		push_error("Failed to pack the scene.")

func create_structure_scene(scene_path: String, root_name: String, size: Vector3) -> void:
	var root = Node3D.new()
	root.name = root_name

	var csg_box = CSGBox3D.new()
	csg_box.name = "Mesh"
	csg_box.size = size
	#csg_box.use_collision = false
	
	place_on_ground(csg_box)

	root.add_child(csg_box)

	export_as_scene(root, scene_path)

func place_on_ground(node: CSGBox3D) -> void:
	node.position.y = node.size.y / 2
