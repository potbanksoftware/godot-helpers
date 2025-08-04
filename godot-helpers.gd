@tool
extends EditorPlugin


func _enter_tree() -> void:
	# Initialization of the plugin goes here.

	if not ProjectSettings.has_setting("autoload/GodotHelpersUtils"):
		add_autoload_singleton("GodotHelpersUtils", "res://addons/godot-helpers/utils.gd")
	
	ProjectSettings.save()


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
