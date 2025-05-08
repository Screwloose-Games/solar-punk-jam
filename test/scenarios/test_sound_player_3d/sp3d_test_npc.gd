extends Node3D

@export var sound_player_3d: AudioStreamPlayer3D
@export var signal_node: Node

func _ready():
    
    var callable = Callable(sound_player_3d, "_on_start")
    print("Object Instance: ", SoundPlayer3D)
    print("callable: ", callable)
    print("signal name: ", sound_player_3d.start_signal_name)
    print("has_method: ", sound_player_3d.has_method("_on_start"))
    print("try_connect_start_result: ", sound_player_3d.try_connect_start_result)
    print("is_connected: ", signal_node.is_connected(sound_player_3d.start_signal_name, callable))
    assert(signal_node.is_connected(sound_player_3d.start_signal_name, callable))
