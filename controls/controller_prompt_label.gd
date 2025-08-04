@tool
class_name ControllerPromptLabel
extends Label

enum ControllerTypeOverride {XBOX_360, XBOX, PLAYSTATION, PS4, PS5, SWITCH, AUTO, TOUCHSCREEN, MOUSE_KEYBOARD}

@export var prompt_text: String = "Do":
	set(value):
		prompt_text = value
		_set_text()

@export var action: String:
	set(value):
		action = value
		_set_text()

@export var controller_type: ControllerTypeOverride = ControllerTypeOverride.AUTO:
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
	if action == "":
		return

	if ControllerImpl.is_touchscreen() or controller_type == ControllerTypeOverride.TOUCHSCREEN:
		text = " %s " % [prompt_text]
	else:
		var action_button = ""

		if controller_type == ControllerTypeOverride.AUTO:
			action_button = ControllerImpl.get_action_button(action)
		elif controller_type == ControllerTypeOverride.MOUSE_KEYBOARD:
			action_button = ControllerImpl.get_key_glyph(action)
		else:
			action_button = ControllerImpl.get_controller_glyph(
				action, controller_type as Controller.ControllerType
			)

		text = " %s %s " % [action_button, prompt_text]
		text = text.strip_edges()
		if prompt_text != "":
			text += " "
