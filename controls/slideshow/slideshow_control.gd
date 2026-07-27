class_name SlideshowControl
extends Control

@export var image_scale: Vector2:
	set(value):
		image_scale = value
		%Slideshow.image_scale = image_scale
@export var images: Array[Texture2D]:
	set(value):
		images = value
		%Slideshow.images = images
