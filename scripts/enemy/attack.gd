extends EnemyState

const SPEED = 20
var direction
var pushback_strength = 10
var attack_damage = 10
var attack_timer_wait_time = 0.6

@onready var attack_timer : Timer = $"./enemy_attack_timer"

func enter(previous_state_path: String, data := {}):
	attack_timer.wait_time = attack_timer_wait_time
	if attack_timer.is_stopped():
		attack_timer.start()


func physics_update(_delta): 
	
	if attack_timer.is_stopped():
		#print("")
		enemy_to_player_attack()
		
		
	direction = player.position - self_enemy.position
	direction = direction.normalized()		
	self_enemy.velocity = (player.get_global_position() - self_enemy.position).normalized() * SPEED * _delta
	self_enemy.move_and_collide(self_enemy.velocity)
	#last_direction = direction
	var angle = direction.angle()
	play_directional_anim(angle, "attack")


func enemy_to_player_attack():
	#if attack_timer.is_stopped():
	if player.has_method("take_player_damage"):
		# also sending the position of the enemy so that character faces the correct direction
		player.take_player_damage(-attack_damage, self_enemy.position, pushback_strength)
		#enemy_attack_timer.start()
		attack_timer.start()
	#else:
		#pass
	#if player_in_attack_range and not player_in_attack_cooldown:
		#if player_body_for_attack.has_method("take_player_damage"):
			## also sending the position of the enemy so that character faces the correct direction
			#player_body_for_attack.take_player_damage(-attack_damage, position, pushback_strength)
			#enemy_attack_timer.start()


func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if self_enemy.is_being_hit == true:
		pass
	elif self_enemy.player_chase == true:
		if direction:
			finished.emit("PlayerChase", {"direction":direction.normalized()})
	else:
		if direction:
			finished.emit("ReturnOriginalPosition", {"direction":direction.normalized()})
