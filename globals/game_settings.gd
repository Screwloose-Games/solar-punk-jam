extends Node

const SETTINGS_FILE_PATH = "user://settings.tres"

@export var settings: Settings


func _ready():
	load_settings_file()
	set_audio_bus("Master", settings.master_volume)
	set_audio_bus("Music", settings.music_volume)
	set_audio_bus("SFX", settings.sfx_volume)
	set_audio_bus("Ambient", settings.ambient_volume)
	set_audio_bus("Dialogue", settings.dialogue_volume)
	set_window_mode(settings.window_mode)


func load_settings_file():
	if ResourceLoader.exists(SETTINGS_FILE_PATH):
		var settings_val = ResourceLoader.load(SETTINGS_FILE_PATH)
		if settings_val:
			# if one of the attributes is missing, don't load the settings file
			if (
				settings_val.sfx_volume == null
				or settings_val.master_volume == null
				or settings_val.music_volume == null
				or settings_val.ambient_volume == null
				or settings_val.dialogue_volume == null
			):
				settings = Settings.new()
			else:
				settings = ResourceLoader.load(SETTINGS_FILE_PATH)


func write_settings():
	ResourceSaver.save(settings, SETTINGS_FILE_PATH)


func set_audio_bus(bus_name: String, percent: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume_db = linear_to_db(percent)
	AudioServer.set_bus_volume_db(bus_index, volume_db)


# This is a simple toggle between Fullscreen and Windowed Mode
# https://docs.godotengine.org/en/stable/classes/class_displayserver.html#class-displayserver-method-window-set-mode
func set_window_mode(mode: DisplayServer.WindowMode):
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func write_back_volume_setting(bus_name: String, percent: float):
	settings.set_bus_volume_percent(bus_name, percent)
	write_settings()


func write_back_display_settings(mode: DisplayServer.WindowMode):
	settings.set_window_mode(mode)
	write_settings()
