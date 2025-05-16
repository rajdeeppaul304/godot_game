extends EnemyState

var direction

@onready var after_hit_timer:Timer = $"./after_hit"

func enter(previous_state_path: String, data := {}):
	direction = data["direction"]
	self_enemy.is_being_after_hit = true
	after_hit_timer.start()

func physics_update(_delta: float) -> void:
	if self_enemy.is_being_after_hit:
		if player:
			self_enemy.modulate = Color(1, 1, 1, 1)
			
			var angle = direction.angle()
			
			play_directional_anim(angle, "idle")
	else:
		if self_enemy.player_chase == true:
			finished.emit("PlayerChase", {"direction":direction.normalized()})
		else:
			finished.emit("Idle", {"direction":direction.normalized()})

func _on_after_hit_timeout() -> void:
	self_enemy.is_being_after_hit = false
