@tool
extends EditorPlugin

func _enter_tree():
	var settings = EditorInterface.get_editor_settings()
	# Use spaces with 2 spaces per block to see more code on GitHub and standardize indent width.
	settings.set_setting("text_editor/behavior/indent/type", 0)
	settings.set_setting("text_editor/behavior/indent/size", 4)
	settings.set_setting("docks/filesystem/textfile_extensions", "txt,md,cfg,ini,log,json,yml,yaml,toml,xml,tsv")
