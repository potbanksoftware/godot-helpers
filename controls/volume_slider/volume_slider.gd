@tool
class_name VolumeSlider
extends MenuControl

signal value_changed

@export var bus_name: String:
	set(value):
		bus_name = value
		_update_label_and_slider()

@export var label_theme: Theme:
	set(value):
		%Label.theme = value
	get:
		return %Label.theme

@export var slider_theme: Theme:
	set(value):
		%HSlider.theme = value
	get:
		return %HSlider.theme

var bus_index: int

var value: float:
	get:
		return %HSlider.value
	set(volume):
		%HSlider.value = volume


func _ready() -> void:
	_update_label_and_slider()


func _update_label_and_slider():
	$MarginContainer/VBoxContainer/Label.text = "%s Volume" % [bus_name]
	if not Engine.is_editor_hint():
		bus_index = AudioServer.get_bus_index(bus_name)
		%HSlider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))


func _on_h_slider_value_changed(_value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(%HSlider.value))
	value_changed.emit()


func _on_h_slider_focus_entered() -> void:
	focus_entered.emit()


func _on_h_slider_focus_exited() -> void:
	focus_exited.emit()


func _on_focus_entered() -> void:
	%HSlider.grab_focus()


func focus() -> void:
	%HSlider.grab_focus()
