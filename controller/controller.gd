extends Node
## Aids for controller/keyboard

## This module should be autoloaded, typically called Controller.

## Emitted when a controller is connected or disconnected.
signal controller_status_changed

enum ControllerType { XBOX_360, XBOX, PLAYSTATION, PS4, PS5, SWITCH, NONE }

var os_name: String = OS.get_name()
var cached_values: Dictionary = {}
var hold_repeat_timer := Timer.new()
var _last_debug_print_args: Array

var controller_debug_template: String = """\
%s controllers connected
First controller is %s
First controller info: %s
First controller GUID: %s\
"""

var _cache_unpopulated: bool = true

var _repeat_action: String
# var _ui_pressed_states: Array[String] = ["ui_up", "ui_down", "ui_left", "ui_right"]
var _ui_pressed_states: Array[String] = ["ui_up", "ui_down"]
# TODO: check if focussed device automatically echos and disable for those actions while focussed


func _ready() -> void:
	Input.connect("joy_connection_changed", _on_input_joy_connection_changed)
	refresh_cache()
	hold_repeat_timer.wait_time = 0.4
	hold_repeat_timer.timeout.connect(_on_hold_repeat_timer_timeout)
	add_child(hold_repeat_timer)
	process_mode = Node.PROCESS_MODE_ALWAYS

	for action_name: String in _ui_pressed_states:
		InputMap.add_action("_true_" + action_name)
		for event: InputEvent in InputMap.action_get_events(action_name):
			InputMap.action_add_event("_true_" + action_name, event)


func _on_input_joy_connection_changed(_device: int, _connected: bool) -> void:
	refresh_cache()
	controller_status_changed.emit()


func _get_glyph_for_event(event: InputEvent, controller: ControllerType) -> Variant:
	var button_map: Dictionary
	var axis_map: Dictionary

	match controller:
		ControllerType.XBOX_360:
			button_map = ControllerMappings.XBOX_BUTTON_MAP.duplicate()
			button_map[JOY_BUTTON_BACK] = PromptFont.GAMEPAD_SELECT  # TODO: proper back button
			button_map[JOY_BUTTON_START] = PromptFont.GAMEPAD_START  # TODO: proper 360 start button
			axis_map = ControllerMappings.XBOX_AXIS_MAP
		ControllerType.XBOX:
			button_map = ControllerMappings.XBOX_BUTTON_MAP
			axis_map = ControllerMappings.XBOX_AXIS_MAP
		ControllerType.PLAYSTATION:
			button_map = ControllerMappings.PLAYSTATION_BUTTON_MAP
			axis_map = ControllerMappings.PLAYSTATION_AXIS_MAP
		ControllerType.PS4:
			button_map = ControllerMappings.PLAYSTATION_BUTTON_MAP.duplicate()
			button_map[JOY_BUTTON_BACK] = PromptFont.SONY_SHARE
			button_map[JOY_BUTTON_START] = PromptFont.SONY_OPTIONS
			axis_map = ControllerMappings.PLAYSTATION_AXIS_MAP
		ControllerType.PS5:
			button_map = ControllerMappings.PLAYSTATION_BUTTON_MAP.duplicate()
			button_map[JOY_BUTTON_BACK] = PromptFont.SONY_SHARE
			button_map[JOY_BUTTON_START] = PromptFont.SONY_DUALSENSE_OPTIONS
			axis_map = ControllerMappings.PLAYSTATION_AXIS_MAP
		ControllerType.SWITCH:
			button_map = ControllerMappings.SWITCH_BUTTON_MAP
			axis_map = ControllerMappings.SWITCH_AXIS_MAP

	if event is InputEventJoypadButton:
		if event.button_index in button_map:
			return button_map[event.button_index]
	elif event is InputEventJoypadMotion:
		if event.axis in axis_map:
			return axis_map[event.axis]

	return null


func get_controller_glyph(action: String, controller: ControllerType) -> String:
	var glyph: Variant
	for event: InputEvent in InputMap.action_get_events(action):
		glyph = _get_glyph_for_event(event, controller)
		if glyph != null:
			return glyph

	return ""


func get_key_glyph(action: String) -> String:
	var keycode: int
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey:
			# keycode = OS.find_keycode_from_string(OS.get_keycode_string(event.physical_keycode))
			keycode = DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)
			if keycode in ControllerMappings.KEY_MAP:
				return ControllerMappings.KEY_MAP[keycode]

	return ""


func refresh_cache() -> void:
	var debug_print_args: Array = [
		Input.get_connected_joypads(),
		Input.get_joy_name(0),
		Input.get_joy_info(0),
		Input.get_joy_guid(0),
	]

	if _last_debug_print_args != debug_print_args:
		_last_debug_print_args = debug_print_args
		print_debug(controller_debug_template % debug_print_args)

	_cache_unpopulated = false
	var controller := controller_type()
	if controller != ControllerType.NONE:
		for action: String in InputMap.get_actions():
			cached_values[action] = get_controller_glyph(action, controller)
		return

	if Controller.is_touchscreen():
		for action: String in InputMap.get_actions():
			cached_values[action] = ""
		return

	for action: String in InputMap.get_actions():
		cached_values[action] = get_key_glyph(action)


## Returns whether any controllers are currently connected.
func controller_connected() -> bool:
	return Input.get_connected_joypads().size() > 0


## Returns the currently connected controller type.
func controller_type() -> ControllerType:
	if not controller_connected():
		return ControllerType.NONE

	var controller_name: String = Input.get_joy_name(0).to_lower()

	print(Input.get_joy_name(0))

	if "xbox" in controller_name:
		return ControllerType.XBOX
	elif "switch" in controller_name:
		return ControllerType.SWITCH
	elif "ps4" in controller_name:
		return ControllerType.PS4
	elif "ps5" in controller_name or "dualsense" in controller_name:
		return ControllerType.PS5
	elif "ps3" in controller_name or "playstation" in controller_name:
		return ControllerType.PLAYSTATION

	# Special Cases
	if controller_name == "gt vx2":
		return ControllerType.PLAYSTATION
	elif controller_name == "nintendo co., ltd. pro controller":
		# Wired Switch Pro Controller
		return ControllerType.SWITCH

	return ControllerType.XBOX


## Returns the promptfont glyph for the given action name (matching the InputMap).
func get_action_button(action: String) -> String:
	if _cache_unpopulated:
		refresh_cache()

	return cached_values[action]


func is_touchscreen() -> bool:
	if os_name == "Android":
		return true
	if os_name == "iOS":
		return true
	if ProjectSettings.get("input_devices/pointing/emulate_touch_from_mouse"):
		var user_prefs := UserPreferences.load_or_create()
		if user_prefs.touch_controls_enabled:
			return true

	return false


func _input(event: InputEvent) -> void:
	if event.is_echo():
		for action: String in _ui_pressed_states:
			if event.is_action(action):
				get_tree().root.set_input_as_handled()


func _process(_delta: float) -> void:
	for action_name: String in _ui_pressed_states:
		if Input.is_action_just_pressed("_true_" + action_name):
			_repeat_action = action_name
			hold_repeat_timer.start()


func _on_hold_repeat_timer_timeout() -> void:
	if not Input.is_action_pressed("_true_" + _repeat_action):
		hold_repeat_timer.stop()
		hold_repeat_timer.wait_time = 0.4
		return

	hold_repeat_timer.wait_time = 0.2
	var event := InputEventAction.new()
	event.action = _repeat_action
	event.pressed = true
	Input.parse_input_event(event)
