extends AudioStreamPlayer

signal track_region_entered(track_id)
signal track_region_exited(track_id)

    
func play_stream(track_id, volume = 0):
    stream.set_sync_stream_volume(track_id, volume)

func stop_stream(track_id):
    stream.set_sync_stream_volume(track_id, -60)