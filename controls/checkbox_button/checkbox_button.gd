@tool
class_name CheckBoxButton
extends MenuControl

signal toggled(toggled_on: bool)

@export var text: String = " CheckBox":
	set(value):
		$CheckBox.text = text
	get:
		return $CheckBox.text

@export var button_pressed: bool:
	set(value):
		$CheckBox.button_pressed = value
	get:
		return $CheckBox.button_pressed

@export var checkbox_theme: Theme:
	set(value):
		$CheckBox.theme = value
	get:
		return $CheckBox.theme

func _ready() -> void:
	$CheckBox.text = text


func _on_check_box_toggled(toggled_on: bool) -> void:
	toggled.emit(toggled_on)


func focus() -> void:
	$CheckBox.grab_focus()
