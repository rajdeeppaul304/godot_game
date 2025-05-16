extends EnemyState

@export var death_particles_Modulate: Color = Color(100, 100, 0.8, 1)
@onready var particles_on_timer: Timer = $particles_on_timer
const ITEM = preload("res://scenes/item.tscn")

signal enemy_died

func enter(previous_state_path: String, data := {}):
	drop_items()
	sprite_2d.visible = false
	self_enemy.modulate = Color(death_particles_Modulate)
	self_enemy.get_node("CollisionShape2D").set_deferred("disabled", true)
	self_enemy.death_particles_big.emitting = true
	self_enemy.death_particles_medium.emitting = true
	self_enemy.death_particles_small.emitting = true
	particles_on_timer.start()
	self_enemy.is_dead = true

func physics_update(_delta: float) -> void:
	self_enemy.modulate = Color(death_particles_Modulate)

#func drop_items():
	#var item = ITEM.instantiate()
#
#
	#item.global_position = self_enemy.global_position
	#self_enemy.get_parent().add_child(item)
	#var temp_vel = ((player.global_position - self_enemy.global_position)).normalized() * 100
	#item.velocity = temp_vel.rotated(randf_range(-1.5, 1.5)) * randf_range(0.9, 1.5)
	#
func drop_items():
	var drop_count = randi_range(0, 5)
	print("Drop count: ", drop_count)

	for i in drop_count:
		var item = ITEM.instantiate()
		
		item.item_name = "HealthPotion" if randf() < 0.5 else "Projectile"
		#self_enemy.get_parent().add_child(item)
		self_enemy.get_parent().call_deferred("add_child", item)
		
		item.global_position = self_enemy.global_position
		
		var enemy_pos = self_enemy.global_position
		var player_pos = player.global_position
		print("Enemy Pos: ", enemy_pos, " | Player Pos: ", player_pos)

		var temp_vel = -(player_pos - enemy_pos).normalized() * 100
		print("Base velocity (away from player): ", temp_vel)

		# Reduced angle randomness
		item.velocity = temp_vel.rotated(randf_range(-1.5, 1.5)) * randf_range(0.9, 1.5)
		print("Final Velocity after randomness: ", item.velocity)


func _on_particles_on_timer_timeout() -> void:
	#drop_items()
	enemy_died.emit()
	self_enemy.queue_free()
