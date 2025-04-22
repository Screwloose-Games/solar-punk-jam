@tool
extends EditorScript

func _run():
	var path = "res://assets/kenney_food-kit/Models/GLB format/advocado-half.glb"
	var new_scene_path = path.get_basename() + ".tscn"
	var main_scene_path = EditorInterface.get_edited_scene_root().scene_file_path
	EditorInterface.open_scene_from_path(path, true)
	EditorInterface.save_scene_as.call_deferred(new_scene_path, false)
	EditorInterface.open_scene_from_path.call_deferred(main_scene_path)
