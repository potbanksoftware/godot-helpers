class_name EngineInputMap
extends Node
## Functions for reading the InputMap in the editor without changing the editor's InputMap.


static func _is_input_property(property: Dictionary) -> bool:
	if property.name.begins_with("input/"):
		if not property.name.ends_with(".macos"):
			return true

	return false


static func get_actions() -> Array[StringName]:
	var actions: Array[StringName]
	for property in ProjectSettings.get_property_list().filter(_is_input_property):
		actions.append(property.name.replace("input/", "") as StringName)

	return actions


static func action_get_events(action: StringName) -> Array[InputEvent]:
	var events: Array[InputEvent] = []
	for event in ProjectSettings.get_setting("input/" + action).events:
		events.append(event as InputEvent)
	return events
