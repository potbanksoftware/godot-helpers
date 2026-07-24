extends Node


func get_debug_menu() -> Variant:
	if ResourceLoader.exists("res://addons/debug_menu/debug_menu.tscn"):
		return get_node_or_null("/root/DebugMenu")
	return null


func print_debug_enum(value: int, enum_type: Dictionary) -> void:
	if OS.is_debug_build():
		@warning_ignore("untyped_declaration")
		var stack_frame = get_stack()[2]

		print(enum_type.find_key(value))
		print("   At: ", stack_frame["source"], ":", stack_frame["line"], ":", stack_frame["function"], "()")


## Returns the sum of two numbers. Useful for Array.reduce
static func sum(accum: float, number: float) -> float:
	return accum + number


## Returns the sum of two integers. Useful for Array.reduce
static func sumi(accum: int, number: int) -> int:
	return accum + number
