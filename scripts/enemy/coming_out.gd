extends EnemyState
signal coming_out_finished

func enter(previous_state_path: String, data := {}):
	self_enemy.visible = false
	pass	

func physics_update(delta):
	if not self_enemy.spawn_broly:
		return
	else:
		self_enemy.visible = true
		animation_player.play("coming_out")
		
		
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "coming_out":
		finished.emit("Idle", {"direction" : Vector2(0,1)})
		coming_out_finished.emit()
