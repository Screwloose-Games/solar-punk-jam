extends AudioStreamPlayer

signal track_region_entered(track_idx, fade_time)
signal track_region_exited(track_idx, fade_time)

	
func play_stream(track_idx, fade_in_time, volume = 0):
	var prop_name = "stream_" + str(track_idx) + "/volume"
	var tween: Tween = get_tree().create_tween()
	
	tween.tween_property(stream, prop_name, volume, fade_in_time)



func stop_stream(track_idx, fade_out_time):
	var prop_name = "stream_" + str(track_idx) + "/volume"
	var tween: Tween = get_tree().create_tween()
	
	tween.tween_property(stream, prop_name, -60, fade_out_time)
