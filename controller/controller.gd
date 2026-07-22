class_name ControllerImpl
extends Node
## Aids for controller/keyboard

## This module should be autoloaded, called Controller.

## Emitted when a controller is connected or disconnected.
signal controller_status_changed

enum ControllerType { NONE, XBOX_360, XBOX, PLAYSTATION, PS4, PS5, SWITCH }
enum InputType { AUTO, XBOX_360, XBOX, PLAYSTATION, PS4, PS5, SWITCH, TOUCHSCREEN, MOUSE_KEYBOARD }

static var input_names: Dictionary = {
	InputType.AUTO: "Auto",
	InputType.XBOX_360: "Xbox 360",
	InputType.XBOX: "Xbox",
	InputType.PLAYSTATION: "PlayStation",
	InputType.PS4: "PS4",
	InputType.PS5: "PS5",
	InputType.SWITCH: "Nintendo Switch",
	InputType.TOUCHSCREEN: "Touchscreen",
	InputType.MOUSE_KEYBOARD: "Mouse + Keyboard",
}
static var input_symbols: Dictionary = {
	InputType.AUTO: "   ",
	InputType.XBOX_360: PromptFont.DEVICE_X360,
	InputType.XBOX: PromptFont.ICON_XBOX,
	InputType.PLAYSTATION: PromptFont.ICON_PLAYSTATION,
	InputType.PS4: PromptFont.DEVICE_DS4,
	InputType.PS5: PromptFont.DEVICE_DUALSENSE,
	InputType.SWITCH: PromptFont.ICON_NINTENDO_SWITCH,
	InputType.TOUCHSCREEN: "   ",
	InputType.MOUSE_KEYBOARD: PromptFont.DEVICE_MOUSE_KEYBOARD,
}

static var os_name: String = OS.get_name()
static var cached_values: Dictionary = {}
static var hold_repeat_timer := Timer.new()
static var _last_debug_print_args: Array
static var input_type_override: InputType = InputType.AUTO

static var controller_debug_template: String = """\
%s controllers connected
First controller is %s
First controller info: %s
First controller GUID: %s\
"""

static var _cache_unpopulated: bool = true

static var _repeat_action: String
# var _ui_pressed_states: Array[String] = ["ui_up", "ui_down", "ui_left", "ui_right"]
static var _ui_pressed_states: Array[String] = ["ui_up", "ui_down"]
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


static func _get_glyph_for_event(event: InputEvent, controller: ControllerType) -> Variant:
	var button_map: Dictionary
	var axis_map: Dictionary

	match controller:
		ControllerType.XBOX_360:
			button_map = ControllerMappings.XBOX_BUTTON_MAP.duplicate()
			button_map[JOY_BUTTON_BACK] = PromptFont.NINTENDO_DPAD_LEFT  # TODO: proper back button
			button_map[JOY_BUTTON_START] = PromptFont.NINTENDO_DPAD_RIGHT  # TODO: proper 360 start button
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


static func get_controller_glyph(action: String, controller: ControllerType) -> String:
	var glyph: Variant
	for event: InputEvent in _action_get_events(action):
		glyph = _get_glyph_for_event(event, controller)
		if glyph != null:
			return glyph

	return ""


static func get_key_glyph(action: String) -> String:
	var keycode: int
	for event: InputEvent in _action_get_events(action):
		if event is InputEventKey:
			# keycode = OS.find_keycode_from_string(OS.get_keycode_string(event.physical_keycode))
			if event.physical_keycode == 0:
				keycode = event.keycode
			elif OS.has_feature("web"):
				# keyboard_get_keycode_from_physical not supported
				keycode = event.physical_keycode
			else:
				keycode = DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)

			if keycode in ControllerMappings.KEY_MAP:
				return ControllerMappings.KEY_MAP[keycode]
		elif event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				return PromptFont.MOUSE_LEFT
			if event.button_index == MOUSE_BUTTON_RIGHT:
				return PromptFont.MOUSE_RIGHT
			if event.button_index == MOUSE_BUTTON_MIDDLE:
				return PromptFont.MOUSE_MIDDLE
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				return PromptFont.MOUSE_SCROLL_UP
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				return PromptFont.MOUSE_SCROLL_DOWN
		elif event is InputEventMouseMotion:
			return PromptFont.MOUSE_ANY
			# return PromptFont.DEVICE_MOUSE

	return ""


## Force a particular input type, e.g. if misdetected or user wants different icons.
func override_input_type(new_type: InputType) -> void:
	input_type_override = new_type
	refresh_cache()
	controller_status_changed.emit()


static func refresh_cache() -> void:
	var debug_print_args: Array = [
		Input.get_connected_joypads(),
		Input.get_joy_name(0),
		Input.get_joy_info(0),
		Input.get_joy_guid(0),
	]

	if not Engine.is_editor_hint() and _last_debug_print_args != debug_print_args:
		_last_debug_print_args = debug_print_args
		print_debug(controller_debug_template % debug_print_args)

	_cache_unpopulated = false
	var input: ControllerImpl.InputType = input_type()

	if input == InputType.TOUCHSCREEN:
		for action: String in _get_actions():
			cached_values[action] = ""
	elif input == InputType.MOUSE_KEYBOARD:
		for action: String in _get_actions():
			cached_values[action] = get_key_glyph(action)
	else:
		assert(input != InputType.AUTO)

		for action: String in _get_actions():
			cached_values[action] = get_controller_glyph(action, input as ControllerType)


static func _get_actions() -> Array[StringName]:
	if not Engine.is_editor_hint():
		return InputMap.get_actions()
	else:
		return EngineInputMap.get_actions()


static func _action_get_events(action: StringName) -> Array[InputEvent]:
	if not Engine.is_editor_hint():
		return InputMap.action_get_events(action)
	else:
		return EngineInputMap.action_get_events(action)


## Returns whether any controllers are currently connected.
static func controller_connected() -> bool:
	return Input.get_connected_joypads().size() > 0


## Returns the currently connected controller type.
static func controller_type() -> ControllerType:
	if not controller_connected():
		return ControllerType.NONE

	var controller_name: String = Input.get_joy_name(0).to_lower()

	print(Input.get_joy_name(0))

	if "xbox" in controller_name and "360" in controller_name:
		return ControllerType.XBOX_360
	elif "xbox" in controller_name:
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


## Returns the current input type (controller variant, touch, M+K etc.).
static func input_type() -> ControllerImpl.InputType:
	var controller: ControllerImpl.ControllerType

	if input_type_override != ControllerImpl.InputType.AUTO:
		return input_type_override

	if Engine.is_editor_hint():
		controller = ControllerImpl.ControllerType.NONE
	else:
		controller = controller_type()

	if controller != ControllerType.NONE:
		return controller as ControllerImpl.InputType

	if is_touchscreen():
		return ControllerImpl.InputType.TOUCHSCREEN

	return ControllerImpl.InputType.MOUSE_KEYBOARD


## Returns the promptfont glyph for the given action name (matching the InputMap).
static func get_action_button(action: String) -> String:
	if _cache_unpopulated or Engine.is_editor_hint():
		refresh_cache()

	return cached_values[action]


static func is_touchscreen() -> bool:
	if os_name == "Android":
		return true
	if os_name == "iOS":
		return true
	if ProjectSettings.get("input_devices/pointing/emulate_touch_from_mouse"):
		# TODO: allow specifying subclass
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
