extends AudioStreamPlayer

func play_ui_sound(sound: AudioStream):
    stream = sound
    play()
    print("playing ui sound: ", stream)

func stop_ui_sound():
    stop()