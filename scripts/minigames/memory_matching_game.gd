extends Node2D

@onready var sprite = $Sprite2D
@onready var button: Button = $Button

var is_flipped = false
var flipping = false
@export var front_texture: Texture2D
@export var back_texture: Texture2D

func flip_card():
	if flipping:
		return
	flipping = true

	# Animate flip_progress from 0.0 to 1.0
	var tween := create_tween()
	tween.tween_property(sprite.material, "shader_parameter/flip_progress", 1.0, 0.4).set_trans(Tween.TRANS_SINE)

	# Halfway point (0.2s) = swap texture
	await get_tree().create_timer(0.2).timeout
	sprite.texture = back_texture if !is_flipped else front_texture
	is_flipped = !is_flipped

	await tween.finished
	sprite.material.set_shader_parameter("flip_progress", 0.0) # Reset for next flip

	# Shake the card after flip
	shake_card()

	flipping = false

func shake_card():
	# Create a shake effect: top goes left, bottom goes right (and vice versa)
	var tween = create_tween()

	# Shake top part
	tween.tween_property(sprite, "position", sprite.position + Vector2(5, -5), 0.05)
	tween.tween_property(sprite, "position", sprite.position - Vector2(5, -5), 0.1)

	# Shake bottom part
	tween.tween_property(sprite, "position", sprite.position - Vector2(5, 5), 0.05)
	tween.tween_property(sprite, "position", sprite.position + Vector2(5, 5), 0.1)


func _on_button_pressed() -> void:
	flip_card()
