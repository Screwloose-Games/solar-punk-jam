extends Control

##Audio
@export var navigate_sound: AudioStream
@export var open_sound: AudioStream
@export var close_sound: AudioStream


func _on_open():
	SoundManager.play_ui_sound(open_sound)


func _on_close():
	SoundManager.play_ui_sound(close_sound)


func _on_hover():
	SoundManager.play_ui_sound(navigate_sound)


func _on_slider_value_changed(_value):
	SoundManager.play_ui_sound(navigate_sound)
