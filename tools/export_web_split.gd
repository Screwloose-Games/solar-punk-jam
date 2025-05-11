

extends EditorExportPlugin
## See docs: https://docs.godotengine.org/en/stable/classes/class_editorexportplugin.html
## To use EditorExportPlugin, register it using the EditorPlugin.add_export_plugin() method first.

func _get_name() -> String:
		return "SplitWebBuildForItch"

func _supports_platform(platform: EditorExportPlatform) -> bool:
		if platform is EditorExportPlatformWeb:
			return true
		return false

func _export_begin( features: PackedStringArray, is_debug: bool, path: String, flags: int ):
    pass
## Virtual method to be overridden by the user. It is called when the export starts and provides all 
## information about the export. features is the list of features for the export, 
## is_debug is true for debug builds, path is the target path for the exported project. 
## flags is only used when running a runnable profile, e.g. when using native run on Android.

func _export_file(path: String, type: String, features: PackedStringArray) -> void:
	if not some_condition in path:
		skip()

func _export_end( )
    ## Virtual method to be overridden by the user. Called when the export is finished.
    pass