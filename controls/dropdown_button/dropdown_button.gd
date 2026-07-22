@tool
class_name DropdownButton
extends PanelControl

signal item_selected(index: int)

@export var text: String = "Dropdown":
	set(value):
		%Label.text = value
	get:
		return %Label.text

var selected: int:
	set(value):
		%OptionButton.selected = value
	get:
		return %OptionButton.selected

@export var label_theme: Theme:
	set(value):
		%Label.theme = value
	get:
		return %Label.theme

@export var dropdown_theme: Theme:
	set(value):
		%OptionButton.theme = value
	get:
		return %OptionButton.theme


func _on_option_button_item_selected(index: int) -> void:
	item_selected.emit(index)


## Adds an item, with text label and (optionally) id. If no id is passed, the item index will be used as the item's ID. New items are appended at the end.
##
## Note: The item will be selected if there are no other items.
func add_item(label: String, id: int = -1) -> void:
	%OptionButton.add_item(label, id)


## Adds a separator to the list of items. Separators help to group items, and can optionally be given a text header. A separator also gets an index assigned, and is appended at the end of the item list.
func add_separator(separator_text: String = "") -> void:
	%OptionButton.add_separator(separator_text)


## Clears all the items in the OptionButton.
func clear() -> void:
	%OptionButton.clear()


func focus() -> void:
	%OptionButton.grab_focus()
