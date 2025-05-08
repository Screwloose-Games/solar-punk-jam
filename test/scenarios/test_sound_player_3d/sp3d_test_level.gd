extends Node3D

@export var sound_player_3d: AudioStreamPlayer3D
func _ready():
    
    var callable = Callable(sound_player_3d, "_on_start")
    print("Object Instance: ", SoundPlayer3D)
    print("callable: ", callable)
    print("signal name: ", sound_player_3d.g_start_signal_name)
    print("has_method: ", sound_player_3d.has_method("_on_start"))
    print("try_connect_g_start_result: ", sound_player_3d.try_connect_g_start_result)
    print("is_connected: ", sound_player_3d.global_signal_bus.is_connected(sound_player_3d.g_start_signal_name, callable))
    assert(sound_player_3d.global_signal_bus.is_connected(sound_player_3d.g_start_signal_name, callable))
