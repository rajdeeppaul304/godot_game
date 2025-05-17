extends EnemyState

const SPEED = 44
var direction
@onready var timer_to_attack_2: Timer = $Timer

func enter(previous_state_path: String, data := {}):
	self_enemy.player_chase = true
	if self_enemy.is_broly:
		timer_to_attack_2.start()
	makepath()
	pass
	
	
#func _physics_process(_delta: float) -> void:
	
	
func physics_update(_delta: float) -> void:
	var next_path_pos = self_enemy.nav_agent.get_next_path_position()
	var dir = self_enemy.global_position.direction_to(next_path_pos)
	self_enemy.velocity = dir * SPEED 
	self_enemy.move_and_slide()
	#self_enemy.move_and_collide(self_enemy.velocity)
	
	
	
	var position = self_enemy.position
	direction = player.position - position
	
	if !self_enemy.nav_agent.is_target_reachable():
		print("Player is outside of navigation bounds.")
		finished.emit("ReturnOriginalPosition", {"direction":direction.normalized()})
	
	if direction.length() > 10:
		#print(self_enemy)
		direction = direction.normalized()
		#position += direction * SPEED * delta

		#last_direction = direction
	
		var angle = direction.angle()
		play_directional_anim(angle, "walk")
		
		#if before_player_chase:
			#play_directional_anim(angle, "aggro")
		#else:
			#play_directional_anim(angle, "walk")

func makepath():
	#pass
	if player:
		self_enemy.nav_agent.target_position = player.global_position

func _on_detection_area_body_exited(body: Node2D) -> void:
	self_enemy.player_chase = false
	if direction:
		finished.emit("ReturnOriginalPosition", {"direction":direction.normalized()})


func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if direction:
		finished.emit("Attack", {"direction":direction.normalized()})


func _on_timer_to_navigate_timeout() -> void:
	makepath()


func _on_timer_timeout() -> void:
	if direction and self_enemy.is_broly and Manager.player_is_alive:
		finished.emit("Attack2", {"direction":direction.normalized()})
