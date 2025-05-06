extends Node

func _ready() -> void:
    
    DynamicMusic.play()
    # false case to sanity check tests
    # assert(DynamicMusic.playing == false)
    
    # test function calls  
    assert(DynamicMusic.playing == true)
    
    DynamicMusic.stop_stream(0)
    assert(DynamicMusic.stream.get_sync_stream_volume(0)  == -60)    
    
    await get_tree().create_timer(1.5).timeout
    DynamicMusic.play_stream(0, 0)
    assert(DynamicMusic.stream.get_sync_stream_volume(0) == 0)
    
    await get_tree().create_timer(30).timeout
    DynamicMusic.stop_stream(1)
    assert(DynamicMusic.stream.get_sync_stream_volume(1) == -60)
