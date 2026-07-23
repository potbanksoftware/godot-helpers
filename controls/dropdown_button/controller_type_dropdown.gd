extends DropdownButton

@export var show_icons: bool = true


func _ready() -> void:
	for controller_type: ControllerImpl.InputType in ControllerImpl.input_names:
		var label: String = ""

		if show_icons:
			label += Controller.input_symbols[controller_type]
			label += "  "

		label += Controller.input_names[controller_type]

		add_item(label, controller_type)

	selected = ControllerImpl.InputType.AUTO


func _on_item_selected(index: int) -> void:
	Controller.override_input_type(index)
