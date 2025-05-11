@tool
extends EditorScript

const MAX_WIDTH := 1024

func _run():
	var root_dir := "res://"
	var large_pngs := find_large_pngs(root_dir, MAX_WIDTH)

	var editor_interface := get_editor_interface()
	var confirmation_dialog := ConfirmationDialog.new()
	confirmation_dialog.dialog_text = "Resize all .png images in '%s' greater than %d pixels to %d pixels?" % [root_dir, MAX_WIDTH, MAX_WIDTH]
	confirmation_dialog.ok_button_text = "Resize"
	confirmation_dialog.get_ok_button().connect("pressed", Callable(self, "_on_confirm_resize").bind(large_pngs))

	editor_interface.get_editor_main_screen().add_child(confirmation_dialog)
	confirmation_dialog.popup_centered()

func _on_confirm_resize(large_pngs):
	for path in large_pngs:
		resize_file(path, MAX_WIDTH)

	print("Resized %d images to a max width of %d." % [large_pngs.size(), MAX_WIDTH])

func find_large_pngs(root_directory: String, max_width: int = MAX_WIDTH) -> Array[String]:
	var large_pngs: Array[String] = []
	var dir := DirAccess.open(root_directory)
	if dir:
		var err = dir.list_dir_begin()
		if err:
			push_error(err)
		var file_name := dir.get_next()
		while file_name != "":
			var path := dir.get_current_dir().path_join(file_name)
			if dir.current_is_dir():
				large_pngs += find_large_pngs(path, max_width)
			elif file_name.to_lower().ends_with(".png"):
				var img := Image.new()
				if img.load(path) == OK and img.get_width() > max_width:
					var rel_path := ProjectSettings.localize_path(path)
					large_pngs.append(rel_path)
			file_name = dir.get_next()
	return large_pngs

func resize_file(png_path: String, max_width: int = MAX_WIDTH) -> void:
	var img := Image.new()
	if img.load(png_path) == OK and img.get_width() > max_width:
		var scale_ratio := max_width / float(img.get_width())
		var new_height := int(img.get_height() * scale_ratio)
		img.resize(max_width, new_height, Image.INTERPOLATE_LANCZOS)
		print("Would overwrite: ", png_path)
		return
		img.save_png(png_path)
