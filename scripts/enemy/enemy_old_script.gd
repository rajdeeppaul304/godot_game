extends CharacterBody2D
# speed and return speed work differently, 
# if you increase speed, speed decreases
# if you increase return_speed it increases normally
const SPEED:float = 45
const RETURN_SPEED = 25  
const RETURN_TIME_RANGE = [2.0, 8.0]
const LERP_STOPPING_VELOCITY = 0.06

var player_chase = false
var before_player_chase = false
var player = null
var projectile_posi = null
var player_body_for_attack = null
var last_direction = Vector2.ZERO
#var original_position = Vector2.ZERO
var returning_to_origin = false
var is_being_hit = false
var after_hit = false
var player_in_attack_range = false
var player_in_attack_cooldown = false
var is_dead = false


@onready var original_position_return: Timer = $original_position_return
@onready var timer_hit: Timer = $MyHurtBox/timer_hit
@onready var enemy_attack_timer: Timer = $Enemy_hitbox/enemy_attack_timer

# death particles
@onready var death_particles_big: CPUParticles2D = $particles/big
@onready var death_particles_medium: CPUParticles2D = $particles/medium
@onready var death_particles_small: CPUParticles2D = $particles/small
@onready var particles_on_timer: Timer = $particles/particles_on_timer


@export var death_particles_Modulate : Color = Color(100,100,0.8,1)
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var max_health:float = 100
@export var attack_damage:float = 10
@export var pushback_strength:float  = 10

var health:int
func connect_player(player_ref):
	player = player_ref
	#print(player, "enemy", Manager.player)

func enemy():
	pass

func _ready():
	
	last_direction = Vector2(0,1)
	
	original_position = position
	health = max_health
	animation_player.play("front_idle")
	
	Manager.emit_connect_player.connect(connect_player)


func _set_health(amount:float):
	health += amount
	if health<=0:
		health = 0
		print("enemy died")
		death_animation()

func death_animation():
	sprite_2d.visible = false
	modulate = Color(death_particles_Modulate)
	$CollisionShape2D.set_deferred("disabled",true)

	
	death_particles_big.emitting = true
	death_particles_medium.emitting = true
	death_particles_small.emitting = true
	particles_on_timer.start()
	is_dead = true
	#print(death_particles_Modulate, "modulate")
	#queue_free()
	
func take_damage(amount:float, posi, damage_name):
	is_being_hit = true
	
	#modulate = Color(100, 100, 3, 1)
	if damage_name in ["melee_1", "melee_2"]:
		
		modulate = Color(100, 1, 1, 1)
	elif damage_name == "melee_3":
		player.apply_noise_shake()
		modulate = Color(100, 100, 100, 1)
	elif damage_name == "projectile_1":
		
		modulate = Color(100, 100, 3, 1)
		#modulate = Color(1.5, 100, 100, 1)
	
	_set_health(-amount)
	
	#print("damage taken" + str(amount))
	#print(health)

	timer_hit.start()
		
	var pushback_force = 5  
	
	print(player.position, "player", posi)

	if player:
		var knockback_dir = (position - player.position).normalized()
		position += knockback_dir * pushback_force
	else:
		projectile_posi = posi
		var knockback_dir = (position - projectile_posi).normalized()
		position += knockback_dir * pushback_force
		
		#print(posi, "this is posi")
	
func _physics_process(delta):
	# is_dead if for the enemy,
	if not is_dead and Manager.player_is_alive:
		main_logic(delta)
		
func main_logic(delta):
	if is_being_hit:
		var angle
		var direction
		if player:
			direction = player.position - position
			direction = direction.normalized()
			last_direction = direction
			angle = direction.angle()
			#run_back_to_origial_posi()
			play_directional_anim(angle, "hit")
	elif after_hit:
		modulate = Color(1, 1, 1, 1)
		var angle = last_direction.angle()
		play_directional_anim(angle, "idle")
	elif player_in_attack_range == true:
		var direction = player.position - position
		direction = direction.normalized()		
		velocity = (player.get_global_position() - position).normalized() * SPEED * delta
		move_and_collide(velocity)
		last_direction = direction
		var angle = direction.angle()
		play_directional_anim(angle, "attack")
	else:
		modulate = Color(1, 1, 1, 1)
		if player_chase:
			# This code is for player_chase
			returning_to_origin = false
			original_position_return.stop()
			var direction = player.position - position
			
			if player_in_attack_cooldown==true:
				last_direction = direction
				var angle = direction.angle()
				play_directional_anim(angle, "idle")
			elif direction.length() > 10:
				direction = direction.normalized()
				#position += direction * SPEED * delta
				
				velocity = (player.get_global_position() - position).normalized() * SPEED * delta
				
				move_and_collide(velocity)

				last_direction = direction

				var angle = direction.angle()
				if before_player_chase:
					play_directional_anim(angle, "aggro")
				else:
					play_directional_anim(angle, "walk")
			else:
				last_direction = (player.position - position).normalized()
				_play_idle_from_direction(last_direction)
		else:
			# this logic is for the enemy to return to its original position
			velocity = lerp(velocity, Vector2.ZERO, LERP_STOPPING_VELOCITY)
			move_and_collide(velocity)

			if not returning_to_origin and not original_position_return.is_stopped():
				_play_idle_from_direction(last_direction)
				

			elif returning_to_origin:
				var return_direction = original_position - position
				if return_direction.length() > 5:
					var move = return_direction.normalized()
					position += move * RETURN_SPEED * delta
					#move_and_collide()

					last_direction = move
					var angle = move.angle()
					play_directional_anim(angle, "walk")
					
				else:
					
					returning_to_origin = false
					_play_idle_from_direction(last_direction)
			else:
				_play_idle_from_direction(last_direction)

func play_directional_anim(angle: float, anim_name: String) -> void:
	if abs(angle) < PI / 4:
		animation_player.play("side_" + anim_name)
		sprite_2d.flip_h = true
	elif abs(angle) > 3 * PI / 4:
		animation_player.play("side_" + anim_name)
		sprite_2d.flip_h = false
	elif angle < 0:
		animation_player.play("back_" + anim_name)
	else:
		animation_player.play("front_" + anim_name)

func _play_idle_from_direction(direction: Vector2):
	if direction == Vector2.ZERO:
		animation_player.play("front_idle")
		return

	var angle = direction.angle()

	#if abs(angle) < PI / 4:
		#animation_player.play("side_idle")
		#sprite_2d.flip_h = true
	#elif abs(angle) > 3 * PI / 4:
		#animation_player.play("side_idle")
		#sprite_2d.flip_h = false
	#elif angle < 0:
		#animation_player.play("back_idle")
	#else:
		#animation_player.play("front_idle")

func run_back_to_origial_posi():
	original_position_return.wait_time = randf_range(RETURN_TIME_RANGE[0], RETURN_TIME_RANGE[1])
	#print(original_position_return.wait_time)
	original_position_return.start()

func enemy_to_player_attack():
	if player_in_attack_range and not player_in_attack_cooldown:
		if player_body_for_attack.has_method("take_player_damage"):
			# also sending the position of the enemy so that character faces the correct direction
			player_body_for_attack.take_player_damage(-attack_damage, position, pushback_strength)
			enemy_attack_timer.start()

func _on_detection_area_body_entered(body: Node2D) -> void:
	# for detection area, the biggest blob in yellow
	player = body
	#before_player_chase(last_direction)
	before_player_chase = true
	player_chase = true
	
func _on_detection_area_body_exited(body: Node2D) -> void:
	# for detection area, the biggest blob in yellow
	player_chase = false
	run_back_to_origial_posi()
	
func _on_original_position_return_timeout() -> void:
	returning_to_origin = true

func _on_timer_hit_timeout() -> void:
	is_being_hit = false
	after_hit = true
	$MyHurtBox/after_hit.start()

func _on_after_hit_timeout() -> void:
	run_back_to_origial_posi()
	after_hit = false

func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	
	player_body_for_attack = body
	#print(body, body.name)
	player_in_attack_range = true
	enemy_attack_timer.start()
	
func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	player_body_for_attack = null
	player_in_attack_range = false
	
func _on_enemy_attack_timer_timeout() -> void:
	player_in_attack_cooldown = false

func _on_particles_on_timer_timeout() -> void:
	queue_free()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	#var current_anim = animation_player.animation
	if anim_name in ["side_aggro", "front_aggro", "back_aggro"]:
		before_player_chase = false
	if "attack" in anim_name:
		enemy_to_player_attack()
		print("attack finished")
		player_in_attack_cooldown = true
