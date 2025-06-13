extends Control

##Audio
@export var navigate_sound: AudioStream
@export var open_sound: AudioStream
@export var close_sound: AudioStream


func _ready():
	GlobalSignalBus.title_screen_started.emit()


func _on_open():
	SoundManager.play_sound(open_sound, GSoundManager.SoundPlayerType.UI)


func _on_close():
	SoundManager.play_sound(close_sound, GSoundManager.SoundPlayerType.UI)


func _on_hover():
	SoundManager.play_sound(navigate_sound, GSoundManager.SoundPlayerType.UI)


func _on_slider_value_changed(_value):
	SoundManager.play_sound(navigate_sound, GSoundManager.SoundPlayerType.UI)
