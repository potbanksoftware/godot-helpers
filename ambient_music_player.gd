extends AudioStreamPlayer
## Automatically play looping ambient music from random position.

@export_range(0, 2) var volume_linear: float = 1.0:
	set(value):
		volume_db = linear_to_db(value)
	get:
		return db_to_linear(volume_db)

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


func fade_out(duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(self, "volume_linear", 0, duration)
	tween.tween_callback(self._fade_callback)


func _fade_callback() -> void:
	stop()
	volume_linear = 1
