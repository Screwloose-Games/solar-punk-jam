extends AudioStreamPlayer
class_name GSoundManager

@onready var ui_sound_player: AudioStreamPlayer = %UiSoundPlayer
@onready var weather_sound_player: AudioStreamPlayer = %WeatherSoundPlayer
@onready var ambient_sound_player: AudioStreamPlayer = %AmbientSoundPlayer

enum SoundPlayerType {
    UI,
    AMBIENT, 
    WEATHER,
}


func get_sound_player(player_type: SoundPlayerType):
    match player_type:
        SoundPlayerType.UI: 
            return ui_sound_player
        SoundPlayerType.WEATHER: 
            return weather_sound_player
        _:
            return null


func play_sound(sound: AudioStream, player_type: SoundPlayerType):
    get_sound_player(player_type).stream = sound
    get_sound_player(player_type).play()
    print("playing ui sound: ", stream)


func stop_sound(player_type: SoundPlayerType):
    get_sound_player(player_type).stop()
