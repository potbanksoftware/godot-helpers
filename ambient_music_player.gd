extends AudioStreamPlayer
## Automatically play looping ambient music from random position.

var rng := RandomNumberGenerator.new()


func _ready() -> void:
	bus = "Music"
	process_mode = PROCESS_MODE_ALWAYS
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(.5))


func start_ambient_music() -> void:
	if stream:
		play(rng.randf_range(0, stream.get_length()))


func change_track(new_stream: AudioStream, random_start: bool = true, force: bool = false) -> void:
	if stream != new_stream or force:
		stream = new_stream
		if random_start:
			start_ambient_music()
		elif stream:
			play(0)

		print_debug("Changed ambient music to ", new_stream)
