@tool
class_name ControllerPromptButton
extends Button

# TODO: overrrides? or are they only useful for static labels
# Might be good to allow user to force style to fix issue with
# detecting their controller.

@export var prompt_text: String = "Do":
	set(value):
		prompt_text = value
		_set_text()

@export var action: String:
	set(value):
		action = value
		_set_text()


func _ready() -> void:
	if not Engine.is_editor_hint():
		Controller.controller_status_changed.connect(_on_controller_changed)
	_on_controller_changed()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if Input.is_action_just_pressed(action):
		ButtonPress.set_simulate_press_texture(self)

		if is_visible_in_tree():
			pressed.emit()

	if Input.is_action_just_released(action):
		ButtonPress.unset_simulate_press_texture(self)


func _on_controller_changed() -> void:
	_set_text()


func _set_text() -> void:
	if action == "":
		return

	if ControllerImpl.is_touchscreen():
		text = " %s " % [prompt_text]
	else:
		text = " %s %s " % [ControllerImpl.get_action_button(action), prompt_text]

	text = text.strip_edges()
	if prompt_text != "":
		text = " %s " % [text]
