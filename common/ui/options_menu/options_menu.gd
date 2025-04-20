class_name OptionsMenu
extends Node

signal back_pressed

var previous_ui: Node
var delete_save_data_pressed_once: bool = false

@onready var window_button = %WindowButton as Button
@onready var master_slider = %MasterSlider
@onready var sfx_slider = %SFXSlider
@onready var music_slider = %MusicSlider
@onready var ambient_slider = %AmbientSlider
@onready var dialogue_slider = %DialogueSlider
@onready var back_button = %BackButton
@onready var delete_save_data_button: Button = %DeleteSaveDataButton


func _ready():
	back_button.pressed.connect(on_back_pressed)
	window_button.pressed.connect(on_window_button_pressed)
	master_slider.value_changed.connect(on_audio_slider_changed.bind("Master"))
	sfx_slider.value_changed.connect(on_audio_slider_changed.bind("SFX"))
	music_slider.value_changed.connect(on_audio_slider_changed.bind("Music"))
	ambient_slider.value_changed.connect(on_audio_slider_changed.bind("Ambient"))
	dialogue_slider.value_changed.connect(on_audio_slider_changed.bind("Dialogue"))
	delete_save_data_button.pressed.connect(try_delete_save_data)

	update_display()


func update_display():
	window_button.text = "Windowed"
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		window_button.text = "Fullscreen"
	master_slider.value = get_bus_volume_percent("Master")
	sfx_slider.value = get_bus_volume_percent("SFX")
	music_slider.value = get_bus_volume_percent("Music")
	ambient_slider.value = get_bus_volume_percent("Ambient")
	dialogue_slider.value = get_bus_volume_percent("Dialogue")


func get_bus_volume_percent(bus_name: String):
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume_db = AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(volume_db)


func set_bus_volume_percent(bus_name: String, percent: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume_db = linear_to_db(percent)
	AudioServer.set_bus_volume_db(bus_index, volume_db)
	GameSettings.write_back_volume_setting(bus_name, percent)


func on_window_button_pressed():
	var mode = DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		GameSettings.set_window_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		GameSettings.set_window_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	GameSettings.write_back_display_settings(DisplayServer.window_get_mode())
	update_display()


func on_audio_slider_changed(value: float, bus_name: String):
	set_bus_volume_percent(bus_name, value)


func on_back_pressed():
	back_pressed.emit()
	delete_save_data_pressed_once = false
	delete_save_data_button.text = "Delete save data."


func try_delete_save_data():
	if not delete_save_data_pressed_once:
		delete_save_data_pressed_once = true
		delete_save_data_button.text = "Delete data for real? You mean it?"

		#CheckpointMgr.delete_save_data()

		#CheckpointMgr.delete_save_data()
	else:
		#CheckpointMgr.delete_save_data()
		delete_save_data_button.text = "Save data deleted"
