class_name PlayCountedAudio extends AudioStreamPlayer

var count: int = 0

func play_counted():
	if count <= 1:
		play()
		count += 1

func stop_counted():
	count = max(0, count - 1)
	if count == 0:
		stop()
