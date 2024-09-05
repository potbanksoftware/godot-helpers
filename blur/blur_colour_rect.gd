extends ColorRect

@export var lod: float= 0.75:
	set(value):
		material.set_shader_parameter("lod", value)
	get:
		return material.get_shader_parameter("lod")
