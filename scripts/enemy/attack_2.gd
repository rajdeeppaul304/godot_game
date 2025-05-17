extends EnemyState

const SPEED = 20  # You can still define speed, but it won't be used here now.
var higher_attack_damage = 15
var pushback_strength = 10
var direction
var target_position
var angle
var attack_timer_wait_time = 0.6
var aoe_sprite
var variable_enemy_hitbox
var did_damage_this_round = false

@onready var attack_timer : Timer = $"./enemy_attack_timer"

func enter(previous_state_path: String, data := {}):
	did_damage_this_round = false
	aoe_sprite = self_enemy.get_node_or_null("aoe")
	variable_enemy_hitbox = self_enemy.get_node_or_null("variable_enemy_hitbox")


	# Get the direction towards the player
	direction = (player.position - self_enemy.position).normalized()
	
	# Calculate the angle to the player for the animation
	angle = direction.angle()

	# Play the attack_2 animation (this plays the entire animation from start to finish)
	play_directional_anim(angle, "attack_2")



func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if "attack_2" in anim_name:
		if aoe_sprite:
			aoe_sprite.visible = true
			aoe_sprite.modulate.a = 1.0

			var shader_mat := aoe_sprite.material as ShaderMaterial
			if shader_mat:
				var tween := create_tween()
				tween.tween_property(shader_mat, "shader_parameter/reveal_radius", 0.5, 0.5).from(0.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

		# Scale the variable_enemy_hitbox outward
		if variable_enemy_hitbox:
			variable_enemy_hitbox.get_node("CollisionShape2D").disabled = false
			var tween := create_tween()
			tween.tween_property(variable_enemy_hitbox, "scale", Vector2.ONE * 10, 0.5).from(Vector2.ZERO).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
		await get_tree().create_timer(0.4).timeout
		var fade_tween := create_tween()
		fade_tween.tween_property(aoe_sprite, "modulate:a", 0.0, 0.3)
		await fade_tween.finished
		aoe_sprite.visible = false
		variable_enemy_hitbox.get_node("CollisionShape2D").disabled = true
		direction = player.position - self_enemy.position
		finished.emit("PlayerChase", {"direction":direction.normalized()})


func _on_variable_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player") and not did_damage_this_round:
		if player.has_method("take_player_damage"):
			did_damage_this_round = true
			# also sending the position of the enemy so that character faces the correct direction
			player.take_player_damage(-higher_attack_damage, self_enemy.position, pushback_strength)
			variable_enemy_hitbox.get_node("CollisionShape2D").disabled = true
