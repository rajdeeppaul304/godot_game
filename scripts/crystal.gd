extends Node2D

@onready var crystal: Sprite2D = $Crystal
const CRYSTAL_ON = preload("res://assets/characters/minigame_assets/broly_level/crystal_on.png")
@export var is_crystal_on = false
signal turned_on(ref)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("player") and not is_crystal_on:
		activate_crystal()
		is_crystal_on = true

func activate_crystal():
	turned_on.emit(self.name)
	z_index = 10
	# Change the crystal's texture to the "on" image
	crystal.texture = CRYSTAL_ON

	# Reset modulate and scale
	crystal.modulate = Color(1, 1, 1, 0)  # Start transparent
	crystal.scale = Vector2(0.7, 0.7)     # Start smaller
	crystal.rotation = 0.0                # Reset rotation

	# Tween sequence
	var tween = create_tween()
	tween.set_parallel(false)  # Run in sequence

	# Step 1: Fade in + scale up
	tween.tween_property(crystal, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(crystal, "scale", Vector2(1.5, 1.5), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Step 2: Pulse scale down
	tween.tween_property(crystal, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Step 3: Subtle rotation wiggle
	#tween.set_parallel(true)  # Run rotation with scale
	#tween.tween_property(crystal, "rotation", deg_to_rad(10), 0.1).set_trans(Tween.TRANS_LINEAR)
	#tween.tween_property(crystal, "rotation", deg_to_rad(-10), 0.2).set_trans(Tween.TRANS_LINEAR)
	#tween.tween_property(crystal, "rotation", 0.0, 0.1).set_trans(Tween.TRANS_LINEAR)

	# Optional: Slight glow using modulate
	tween.set_parallel(false)
	tween.tween_property(crystal, "modulate", Color(1.2, 1.2, 1.5, 1.0), 0.1)
	tween.tween_property(crystal, "modulate", Color(1, 1, 1, 1.0), 0.3)
	
	await tween.finished
	z_index = 2
