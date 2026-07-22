class_name UserPreferences
extends Resource

@export_range(0, 1, 0.05) var master_audio_level: float = 1.0
@export_range(0, 1, 0.05) var sfx_audio_level: float = 1.0
@export_range(0, 1, 0.05) var music_audio_level: float = 0.5
@export var debug_menu_style: int = 0
@export var vsync_enabled: bool = true
@export var touch_controls_enabled: bool = false
@export var input_type: int = ControllerImpl.InputType.AUTO


func save() -> void:
	ResourceSaver.save(self, "user://user_prefs.tres")


# TODO: allow subclassing
static func load_or_create() -> UserPreferences:
	# TODO: Use ResourceLoader?
	var res: UserPreferences = load("user://user_prefs.tres") as UserPreferences
	if not res:
		res = UserPreferences.new()

		var master_bus_index: int = AudioServer.get_bus_index("Master")
		res.master_audio_level = db_to_linear(AudioServer.get_bus_volume_db(master_bus_index))

		var sfx_bus_index: int = AudioServer.get_bus_index("SFX")
		res.sfx_audio_level = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus_index))

		var music_bus_index: int = AudioServer.get_bus_index("Music")
		res.music_audio_level = db_to_linear(AudioServer.get_bus_volume_db(music_bus_index))

		match DisplayServer.window_get_vsync_mode():
			DisplayServer.VSYNC_ENABLED:
				res.vsync_enabled = true
			DisplayServer.VSYNC_DISABLED:
				res.vsync_enabled = false
			_:
				print_debug(DisplayServer.window_get_vsync_mode())

		var debug_menu: Node = GodotHelpersUtils.get_debug_menu()
		if debug_menu != null:
			res.debug_menu_style = debug_menu.style

	return res
