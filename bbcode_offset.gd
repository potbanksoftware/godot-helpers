@tool
class_name RichTextOffset
extends RichTextEffect
## RichTextLabel effect to offset text vertically.

var bbcode: String = "offset"


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var x: int = char_fx.env.get("x", 0)
	var y: int = char_fx.env.get("y", 0)
	char_fx.offset = Vector2(x, y)

	return true
