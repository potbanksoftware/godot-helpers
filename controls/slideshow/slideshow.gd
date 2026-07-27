class_name Slideshow
extends Node2D

# TODO: allow changing image size (affects end position in AnimationPlayer and Sprite2D sizes)

@export var image_scale: Vector2
@export var images: Array[Texture2D]
var image_idx: int = -1


func _ready() -> void:
	$Image0.scale = image_scale
	$Image1.scale = image_scale
	$Image2.scale = image_scale
	load_next_image()


func _process(_delta: float) -> void:
	if not $AnimationPlayer.is_playing():
		if Input.is_action_just_pressed("ui_right"):
			next()
		elif Input.is_action_just_pressed("ui_left"):
			previous()


func load_next_image() -> void:
	$Image0.texture = images[image_idx]
	image_idx = (image_idx + 1) % len(images)
	var next_image_idx: int = (image_idx + 1) % len(images)
	$Image1.texture = images[image_idx]
	$Image2.texture = images[next_image_idx]
	$Camera2D.position = Vector2i.ZERO


func load_prev_image() -> void:
	$Image2.texture = images[image_idx]
	image_idx = (image_idx - 1) % len(images)
	var prev_image_idx: int = (image_idx - 1) % len(images)
	$Image0.texture = images[prev_image_idx]
	$Image1.texture = images[image_idx]
	$Camera2D.position = Vector2i.ZERO


func next() -> void:
	$AnimationPlayer.play("next_image")


func previous() -> void:
	$AnimationPlayer.play("prev_image")
