# Script attached to the GridMap node
extends GridMap

# --- Configuration ---
# Assign all PackedScene files that represent objects you might want to instance
# via the GridMap.
@export var scenes_to_instance: Array[PackedScene]

# Optional: Assign a node (e.g., a plain Node3D) where instances
# will be added. If left null, they will be added as children of
# the GridMap's parent. Good for organization.
@export var instance_container: Node3D

# --- Private Variables ---
# Dictionary mapping: MeshLibrary item name -> PackedScene
var _item_name_to_scene_map: Dictionary = {}
var _container_node: Node


func _ready():
	# Ensure the GridMap has a MeshLibrary assigned
	await get_tree().create_timer(0.1).timeout
	if not mesh_library:
		printerr("GridMap node '%s' requires a MeshLibrary resource." % name)
		set_process(false) # Disable processing if no library
		return

	# Determine where to add the instanced scenes
	if instance_container:
		_container_node = instance_container
	else:
		_container_node = get_parent() # Default to GridMap's parent

	if not _container_node:
		printerr("Cannot instance scenes: No valid container node found or assigned, and GridMap has no parent.")
		set_process(false) # Disable processing
		return

	# Build the map connecting MeshLibrary item names to PackedScenes
	_build_item_name_to_scene_map()

	# If the map is successfully built (or partially built), proceed
	if not _item_name_to_scene_map.is_empty():
		_replace_placeholders_with_scenes()
	else:
		print("No valid scene mappings found. No replacements performed.")


# Builds the dictionary mapping MeshLibrary item names to PackedScenes
func _build_item_name_to_scene_map():
	print("Building MeshLibrary item name to PackedScene map...")
	_item_name_to_scene_map.clear()

	for i in range(scenes_to_instance.size()):
		var packed_scene: PackedScene = scenes_to_instance[i]

		if not packed_scene or not packed_scene.can_instantiate():
			push_warning("Scene at index %d in scenes_to_instance is null or invalid." % i)
			continue

		# Instantiate temporarily to inspect the hierarchy
		# Use GEN_EDIT_STATE_DISABLED for potentially slightly faster instantiation
		# as we don't need editor-specific information.
		var temp_instance: Node = packed_scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		if not temp_instance:
			push_warning("Failed to temporarily instantiate scene: %s" % packed_scene.resource_path)
			continue

		# Find the name of the first MeshInstance3D node in the scene
		var mesh_node_name: StringName = _find_first_mesh_instance_name(temp_instance)

		if mesh_node_name != &"":
			# Assume this mesh name corresponds to an item name in the MeshLibrary
			if _item_name_to_scene_map.has(mesh_node_name):
				push_warning("Duplicate mesh name '%s' found. Mapping for scene '%s' might overwrite another." % [mesh_node_name, packed_scene.resource_path])
			_item_name_to_scene_map[mesh_node_name] = packed_scene
			print("  Mapped MeshLibrary item '%s' -> Scene '%s'" % [mesh_node_name, packed_scene.resource_path])
		else:
			push_warning("Could not find any MeshInstance3D node in scene: %s. Cannot automatically map it." % packed_scene.resource_path)

		# IMPORTANT: Clean up the temporary instance
		temp_instance.queue_free()

	print("Map building complete.")


# Helper function to recursively find the first MeshInstance3D in a node tree
# Returns the name of the first MeshInstance3D found, or &"" if none found.
func _find_first_mesh_instance_name(node: Node) -> StringName:
	# Check if the current node itself is a MeshInstance3D
	if node is MeshInstance3D:
		return node.name # Found one!

	# If not, recursively check children
	for child in node.get_children():
		var found_name: StringName = _find_first_mesh_instance_name(child)
		if found_name != &"":
			return found_name # Return the first one found in children

	# If no MeshInstance3D found in this branch
	return &""


# Iterates through used cells and replaces placeholders based on the mapped scenes
func _replace_placeholders_with_scenes():
	print("Replacing GridMap placeholders with mapped scenes...")
	var used_cells: Array[Vector3i] = get_used_cells()
	var replacements_done = 0

	for cell_coord: Vector3i in used_cells:
		var item_index: int = get_cell_item(cell_coord)

		# Check if item index is valid
		if item_index == GridMap.INVALID_CELL_ITEM:
			continue

		# Get the name associated with this item index in the MeshLibrary
		var item_name: StringName = mesh_library.get_item_name(item_index)

		if item_name == &"":
			# This might happen if an item exists but has no name? Or index is somehow invalid.
			# print("Skipping cell %s: Item index %d has no name in MeshLibrary." % [cell_coord, item_index])
			continue

		# Check if this item name exists in our automatically generated map
		if _item_name_to_scene_map.has(item_name):
			var packed_scene: PackedScene = _item_name_to_scene_map[item_name]

			# --- Perform the replacement ---
			# 1. Calculate the world position
			var local_pos: Vector3 = map_to_local(cell_coord)
			var world_pos: Vector3 = to_global(local_pos)

			# 2. Instance the scene
			var instance = packed_scene.instantiate()

			# 3. Add the instance to the scene tree (under the container)
			_container_node.add_child(instance)

			# 4. Set the instance's position and potentially orientation
			if instance is Node3D:
				instance.global_position = world_pos
				# Optional: Apply rotation based on grid orientation if needed
				# var orientation = get_cell_item_orientation(cell_coord)
				# var basis = Basis(Vector3.UP, PI * 0.5 * orientation) # Example rotation
				# instance.global_transform.basis = basis * instance.global_transform.basis
			else:
				push_warning("Instanced scene root node '%s' is not a Node3D, cannot set global_position." % instance.name)

			# 5. Remove the placeholder tile from the GridMap
			set_cell_item(cell_coord, GridMap.INVALID_CELL_ITEM)
			replacements_done += 1
			# --- Replacement done ---

	print("Finished replacing placeholders. %d replacements made." % replacements_done)
