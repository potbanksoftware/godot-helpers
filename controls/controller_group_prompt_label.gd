class_name ControllerGroupPromptLabel
extends Label

enum ControlGroup { WASD_LS, ARROWS_DPAD, MOUSE_RS }
enum ControllerTypeOverride {XBOX_360, XBOX, PLAYSTATION, PS4, PS5, SWITCH, AUTO, TOUCHSCREEN, MOUSE_KEYBOARD}

@export var group: ControlGroup = ControlGroup.WASD_LS:
	set(value):
		group = value

@export var prompt_text: String:
	set(value):
		prompt_text = value
		_set_text()

@export var controller_type: ControllerTypeOverride = ControllerTypeOverride.AUTO


func _ready() -> void:
	Controller.controller_status_changed.connect(_on_controller_changed)
	_on_controller_changed()


func _on_controller_changed() -> void:
	_set_text()


func _set_text() -> void:
	var controller: Controller.ControllerType
	if controller_type == ControllerTypeOverride.AUTO:
		controller = Controller.controller_type()
	elif controller_type == ControllerTypeOverride.MOUSE_KEYBOARD:
		controller = Controller.ControllerType.NONE
	elif controller_type == ControllerTypeOverride.TOUCHSCREEN:
		controller = Controller.ControllerType.NONE  # TODO
	else:
		controller = controller_type as Controller.ControllerType

	var symbols: Array[String] = [PromptFont.ANALOG_L, PromptFont.DPAD, PromptFont.ANALOG_R]

	match controller:
		#Controller.ControllerType.XBOX_360:
		#	symbols = [PromptFont.ANALOG_L, PromptFont.DPAD, PromptFont.ANALOG_R]
		#Controller.ControllerType.XBOX:
		#	symbols = [PromptFont.ANALOG_L, PromptFont.DPAD, PromptFont.ANALOG_R]
		#Controller.ControllerType.PLAYSTATION:
		#	symbols = [PromptFont.ANALOG_L, PromptFont.DPAD, PromptFont.ANALOG_R]
		#Controller.ControllerType.PS4:
		#	symbols = [PromptFont.ANALOG_L, PromptFont.DPAD, PromptFont.ANALOG_R]
		#Controller.ControllerType.SWITCH:
		#	symbols = [PromptFont.ANALOG_L, PromptFont.DPAD, PromptFont.ANALOG_R]
		Controller.ControllerType.NONE:
			if Controller.is_touchscreen():
				symbols = ["", "", ""]
			else:
				symbols = [PromptFont.KEYBOARD_WASD, PromptFont.KEYBOARD_ARROWS, PromptFont.DEVICE_MOUSE]

	print_debug(Controller.controller_type())

	#if Controller.is_touchscreen():
	#	text = " %s " % [prompt_text]
	##else:
	text = " %s %s " % [symbols[group], prompt_text]
	text = text.strip_edges()
	if prompt_text != "":
		text += " "
