extends EnemyState

var direction

@onready var timer_hit:Timer = $"./timer_hit"

func enter(previous_state_path: String, data := {}):
	self_enemy.is_being_hit = true
	var amount = data["amount"]
	#var posi = data["posi"]
	var damage_name = data["damage_name"]
	var knockback = data["knockback"]
	
	if damage_name in ["melee_1", "melee_2"]:
		self_enemy.modulate = Color(100, 1, 1, 1)
	elif damage_name == "melee_3":
		player.apply_noise_shake()
		self_enemy.modulate = Color(100, 100, 100, 1)
	elif damage_name == "projectile_1":
		self_enemy.modulate = Color(100, 100, 3, 1)
	
	self_enemy._set_health((-float(amount)))
	timer_hit.start()
	
	var pushback_force = knockback
	print("pushback_force") 
	print(pushback_force) 
	#print(player.position, "player", posi)
	if player:
		var knockback_dir = (self_enemy.position - player.position).normalized()
		self_enemy.position += knockback_dir * pushback_force
	#else:
		#projectile_posi = posi
		#var knockback_dir = (position - projectile_posi).normalized()
		#position += knockback_dir * pushback_force

func exit():
	self_enemy.is_being_hit = false

func physics_update(_delta: float) -> void:
	if self_enemy.is_being_hit:
		
		var angle
		#direction
		if player:
			direction = player.position - self_enemy.position
			direction = direction.normalized()
			#last_direction = direction
			angle = direction.angle()
			#run_back_to_origial_posi()
			play_directional_anim(angle, "hit")
	else:
		direction = player.position - self_enemy.position
		finished.emit("AfterHit", {"direction":direction.normalized()})
		#if self_enemy.player_chase == true:
			#finished.emit("PlayerChase", {"direction":direction.normalized()})


func _on_timer_hit_timeout() -> void:
	self_enemy.modulate = Color(1, 1, 1, 1)
	self_enemy.is_being_hit = false
