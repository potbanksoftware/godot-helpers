class_name ButtonPress
## Helpers to visually simulate UI button presses when controller button or keyboard key pressed
## Requires button to have a theme set.
##
## Example Usage
##	if Input.is_action_just_pressed("ui_accept"):
##		ButtonPress.set_simulate_press_texture(self)
##		# Do something
##
##	if Input.is_action_just_released("ui_accept"):
##		ButtonPress.unset_simulate_press_texture(self)


## Set `normal` and `hover` textures to the pressed texture.
static func set_simulate_press_texture(button: Button) -> void:
	button.set("theme_override_styles/normal", button.theme.get_stylebox("pressed", "Button"))
	button.set("theme_override_styles/hover", button.theme.get_stylebox("pressed", "Button"))


## Set `normal` and `hover` textures back to theme defaults.
static func unset_simulate_press_texture(button: Button) -> void:
	button.set("theme_override_styles/normal", null)
	button.set("theme_override_styles/hover", null)
