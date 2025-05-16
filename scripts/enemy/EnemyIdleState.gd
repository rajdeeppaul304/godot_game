extends EnemyState

#var player

var current_animation = null

func enter(previous_state_path: String, data := {}):
	#print(previous_state_path, "error here")
	var direction = data["direction"]
	#if data["start_direction"]:
	if direction == Vector2.ZERO:
		animation_player.play("front_idle")
		return
		
	if direction:
		var angle = direction.angle()

		if abs(angle) < PI / 4:
			animation_player.play("side_idle")
			current_animation = "side_idle"
			sprite_2d.flip_h = true
		elif abs(angle) > 3 * PI / 4:
			animation_player.play("side_idle")
			current_animation = "side_idle"
			sprite_2d.flip_h = false
		elif angle < 0:
			animation_player.play("back_idle")
			current_animation = "back_idle"
		else:
			animation_player.play("front_idle")
			current_animation = "front_idle"
	else:
		print("no animation supplied")
		animation_player.play("side_idle")
		current_animation = "side_idle"
		sprite_2d.flip_h = true
		
	#animation_player.play("front_idle")


func physics_update(_delta: float) -> void:
	if current_animation != null:
		animation_player.play(current_animation)
	pass

func exit():
	current_animation = null


func _on_detection_area_body_entered(body: Node2D) -> void:
	finished.emit("PlayerChase")
