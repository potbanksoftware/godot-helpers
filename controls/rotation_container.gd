@tool
class_name RotationContainer
extends Container

# From https://forum.godotengine.org/t/any-way-to-rotate-a-control-90-degrees/104901/7


func _get_minimum_size() -> Vector2:
	var children_size: Vector2
	for child in get_children():
		var min_size: Vector2 = child.get_minimum_size()

		if child.visible:
			children_size.x = max(children_size.x, min_size.x)
			children_size.y = max(children_size.y, min_size.y)

	return Vector2(children_size.y, children_size.x)


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		var s: Vector2 = size

		for child in get_children():
			child.rotation = PI / 2
			child.position = Vector2(s.x, 0)
			child.size = Vector2(s.y, s.x)

	if what == NOTIFICATION_THEME_CHANGED:
		update_minimum_size()
