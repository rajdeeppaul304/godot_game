extends EnemyState

const RETURN_SPEED = 40
var direction
var start_returning:bool = false

@onready var original_position_return:Timer = $"original_position_return"

func enter(previous_state_path: String, data := {}) -> void:
	original_position_return.start()
	


func physics_update(_delta):
	var return_direction = self_enemy.original_position - self_enemy.position
	direction = return_direction.normalized()
	var angle = self_enemy.velocity.angle()
	if start_returning == true:
		if return_direction.length() > 5:
			self_enemy.velocity = direction * RETURN_SPEED * _delta
			self_enemy.move_and_collide(self_enemy.velocity)
			play_directional_anim(angle, "walk")
		else:
			#finished.emit("Idle")
			finished.emit("Idle", {"direction":direction})
	else:
		play_directional_anim(angle, "idle")

func exit():
	original_position_return.stop()
	start_returning = false
	
func _on_original_position_return_timeout() -> void:
	start_returning = true
