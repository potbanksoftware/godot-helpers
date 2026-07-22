@tool
class_name ControllerGroupPromptLabel
extends Label

enum ControlGroup { WASD_LS, ARROWS_DPAD, MOUSE_RS }

@export var group: ControlGroup = ControlGroup.WASD_LS:
	set(value):
		group = value

@export var prompt_text: String = "Do":
	set(value):
		prompt_text = value
		_set_text()

@export var controller_type: ControllerImpl.InputType = ControllerImpl.InputType.AUTO:
	set(value):
		controller_type = value
		_set_text()


func _ready() -> void:
	if not Engine.is_editor_hint():
		Controller.controller_status_changed.connect(_on_controller_changed)
	_on_controller_changed()


func _on_controller_changed() -> void:
	_set_text()


func _set_text() -> void:
	var controller: ControllerImpl.InputType
	if controller_type == ControllerImpl.InputType.AUTO:
		controller = ControllerImpl.input_type()
	else:
		controller = controller_type

	assert(controller != ControllerImpl.InputType.AUTO)

	var symbols: Array[String] = [PromptFont.ANALOG_L, PromptFont.DPAD, PromptFont.ANALOG_R]

	match controller:
		ControllerImpl.ControllerType.XBOX_360:
			symbols = [PromptFont.ANALOG_L, PromptFont.XBOX_DPAD, PromptFont.ANALOG_R]
		ControllerImpl.ControllerType.XBOX:
			symbols = [PromptFont.ANALOG_L, PromptFont.XBOX_DPAD, PromptFont.ANALOG_R]
		#ControllerImpl.ControllerType.PLAYSTATION:
		#	symbols = [PromptFont.ANALOG_L, PromptFont.DPAD, PromptFont.ANALOG_R]
		#ControllerImpl.ControllerType.PS4:
		#	symbols = [PromptFont.ANALOG_L, PromptFont.DPAD, PromptFont.ANALOG_R]
		#ControllerImpl.ControllerType.SWITCH:
		#	symbols = [PromptFont.ANALOG_L, PromptFont.DPAD, PromptFont.ANALOG_R]
		ControllerImpl.InputType.TOUCHSCREEN:
			symbols = ["", "", ""]
		ControllerImpl.InputType.MOUSE_KEYBOARD:
			symbols = [PromptFont.KEYBOARD_WASD, PromptFont.KEYBOARD_ARROWS, PromptFont.MOUSE_ANY]
			# symbols = [PromptFont.KEYBOARD_WASD, PromptFont.KEYBOARD_ARROWS, PromptFont.DEVICE_MOUSE]

	#if Controller.is_touchscreen():
	#	text = " %s " % [prompt_text]
	##else:
	text = " %s %s " % [symbols[group], prompt_text]
	text = text.strip_edges()
	if prompt_text != "":
		text = " %s " % [text]
