extends Node


func get_debug_menu() -> Variant:
	if ResourceLoader.exists("res://addons/debug_menu/debug_menu.tscn"):
		return get_node_or_null("/root/DebugMenu")
	return null
