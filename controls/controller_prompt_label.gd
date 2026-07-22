@tool
class_name ControllerPromptLabel
extends Label

@export var prompt_text: String = "Do":
	set(value):
		prompt_text = value
		_set_text()

@export var action: String:
	set(value):
		action = value
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
	if action == "":
		return

	var controller: ControllerImpl.InputType
	if controller_type == ControllerImpl.InputType.AUTO:
		controller = ControllerImpl.input_type()
	else:
		controller = controller_type

	assert(controller != ControllerImpl.InputType.AUTO)

	if controller == ControllerImpl.InputType.TOUCHSCREEN:
		text = " %s " % [prompt_text]
	else:
		var action_button: String = ""

		if controller == ControllerImpl.InputType.MOUSE_KEYBOARD:
			action_button = ControllerImpl.get_key_glyph(action)
		else:
			action_button = ControllerImpl.get_controller_glyph(
				action, controller as Controller.ControllerType
			)

		text = " %s %s " % [action_button, prompt_text]
		text = text.strip_edges()
		if prompt_text != "":
			text = " %s " % [text]
