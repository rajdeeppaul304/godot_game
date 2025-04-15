class_name Player
extends CharacterBody2D

@export var projectile_tex : Texture2D

# items picked by Player
#@export var projectile_count:int = 100
#@export var health_potion_count:int = 100


@export var damage_melee_1:float = 10
@export var damage_melee_2:float = 15
@export var damage_melee_3:float = 20



# for shake effect
# How quickly to move through the noise
@export var NOISE_SHAKE_SPEED: float = 30.0
# Noise returns values in the range (-1, 1)
# So this is how much to multiply the returned value by
@export var NOISE_SHAKE_STRENGTH: float = 30
# Multiplier for lerping the shake strength to zero
@export var SHAKE_DECAY_RATE: float = 5.0


var projectile_path = preload("res://scenes/projectile.tscn")
var death_screen = preload("res://scenes/death_screen.tscn")

const speed = 2
const sprint_speed = 3
var current_dir = "right"

var enemy_in_attack_range = false
var enemies_in_range = 0
var enemy_attack_cooldown = true
#var health:float
var player_alive = true
var player_being_hit = false



# attack variables 
var attack_ip = false
var can_attack = true
var can_second_attack = false
var second_attack_pressed = false
var can_third_attack = false
var third_attack_pressed = false
var current_attack_anim = "melee_1"
var shooting_projectile = false
var can_shoot_projectile = true


# for camera shake
var noise_i: float = 0.0
var shake_strength: float = 0.0



@onready var camera:Camera2D = $Camera2D

@onready var rand = RandomNumberGenerator.new()
@onready var noise: FastNoiseLite = FastNoiseLite.new()

# HUD elements
@onready var health_bar: TextureProgressBar = $canvas_hud/health_bar
@onready var health_potion_count_label: Label = $canvas_hud/health_potion_label_group/health_potion_count_label
@onready var ranged_bar: TextureProgressBar = $canvas_hud/ranged_bar
@onready var ranged_count_label: Label = $canvas_hud/ranged_group/ranged_count_label



@onready var ranged_timer: Timer = $timers/ranged_timer


@onready var attack_cooldown: Timer = $timers/attack_cooldown
@onready var timer_after_melee_3: Timer = $timers/timer_after_melee_3

@onready var combo_timer: Timer = $timers/combo_timer
@onready var projectile_detection: Area2D = $projectile_detection

@onready var debug_label: Label = $debugLabel


@onready var my_hit_box: MyHitBox = $MyHitBox
@onready var hitbox_collisionshape: CollisionShape2D = $"MyHitBox/CollisionShape2D"

@onready var player_sprite: Sprite2D = $Sprite2D
@onready var anim = $AnimationPlayer

@onready var projectile_aim: Area2D = $projectile_aim

signal player_registered(player_ref: CharacterBody2D)

func item_picked(item_name):
	if item_name == "HealthPotion":
		Manager.health_potion_count += 1
		health_potion_count_label.text = str(Manager.health_potion_count)
	elif item_name == "Projectile":
		Manager.projectile_count += 1
		ranged_count_label.text = str(Manager.projectile_count)

func apply_noise_shake() -> void:
	shake_strength = NOISE_SHAKE_STRENGTH

func get_noise_offset(delta: float) -> Vector2:
	noise_i += delta * NOISE_SHAKE_SPEED
	return Vector2(
		noise.get_noise_2d(1.0, noise_i) * shake_strength,
		noise.get_noise_2d(100.0, noise_i) * shake_strength
	)

func _ready():
	
	#camera = get_parent()
	
	if Manager.player_is_alive:
		
		#if player_sprite.material and player_sprite.material.has_parameter("progress"):
		player_sprite.material.set_shader_parameter("progress", 0.0)
		#modulate = Color(1, 1, 1, 1)
		default_everything()
		visible = true
		Manager.item_picked_by_player.connect(item_picked)
		health_potion_count_label.text = str(Manager.health_potion_count)
		ranged_count_label.text = str(Manager.projectile_count)
		
		
		#if Manager.has_singleton("manager"): # Optional safety
		player_registered.connect(Manager._on_player_registered)

		# Emit signal and pass self reference
		Manager.register_player(self)
		player_registered.emit(self)
		

		#Manager.player_health = Manager.max_player_health	
		health_bar.max_value = Manager.max_player_health
		

		health_bar.value = Manager.player_health
		
		#$AnimatedSprite2D.play("front_idle")
		# at the start of the match setting the damage of the hitbox as the export var
		my_hit_box.set_damage(damage_melee_1)
		
		rand.randomize()
		noise.seed = rand.randi()
		noise.frequency = 0.5  # Lower frequency = smoother noise (similar to period in OpenSimplexNoise)
		noise.noise_type = FastNoiseLite.TYPE_SIMPLEX  # You can try TYPE_PERLIN or others too

		#hitbox_collisionshape.disabled = true
	

func _input(event: InputEvent) -> void:
	if Manager.player_is_alive:
		if Input.is_action_just_pressed("attack"):
			
			if can_third_attack == true:
				third_attack_pressed = true
			else:
				if can_second_attack:
					second_attack_pressed = true
				elif can_attack:
					attack_cooldown.start()
					can_attack = false
					attack_ip = true
		if Input.is_action_just_pressed("projectile_1"):
			if (can_shoot_projectile == true) and (Manager.projectile_count>0):
				shoot_projectile()
		
		if Input.is_action_just_pressed("health_potion"):
			drink_health_potion()

func _set_health(amount:float):
	Manager.player_health += amount
	if Manager.player_health<=0:
		Manager.player_health = 0
		
	health_bar.value = Manager.player_health
	
	if Manager.player_health <= 0 :
		death_player()
		#queue_free()

func generate_noise_texture(size := 128) -> ImageTexture:
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.1

	var image = Image.create(size, size, false, Image.FORMAT_RF)

	for y in size:
		for x in size:
			var value = noise.get_noise_2d(x, y) * 0.5 + 0.5  # Normalize to 0-1
			image.set_pixel(x, y, Color(value, 0, 0))  # R channel only

	var texture = ImageTexture.create_from_image(image)
	return texture

func death_player():
	Manager.player_is_alive = false
	#death_screen
	
	var noise_texture = generate_noise_texture()
	player_sprite.material.set_shader_parameter("noise_tex", noise_texture)
	
	var mat = player_sprite.material
	#
	var tween = create_tween()
	tween.tween_property(mat, "shader_parameter/progress", 1.0, 2)

	tween.parallel().tween_property(player_sprite, "modulate:a", 0.0, 2)

	
	await tween.finished
	
	
	var death_screen_instance =  death_screen.instantiate()
	add_child(death_screen_instance)
	
	
	death_screen_instance.start_death_screen()
	$canvas_hud.visible = false
	$canvas_hud/touch_controls.visible = false

func drink_health_potion():
	if Manager.health_potion_count<1:
		push_warning("no health potion left")
	else:
		if Manager.player_health < Manager.max_player_health:
			Manager.health_potion_count -= 1
			health_potion_count_label.text = str(Manager.health_potion_count)
			_set_health(+20)

func shoot_projectile():			
	var enemies = get_enemies_in_area()

	var player_posi = projectile_aim.global_position
	
	if enemies.size() == 0:
		push_warning("no enemies in vicinity")
		return

	# Find the closest enemy
	var closest_enemy_pos = enemies[0]
	#var shortest_distance = global_position.distance_to(closest_enemy_pos)
	var shortest_distance = player_posi.distance_to(closest_enemy_pos)

	for enemy_pos in enemies:
		#var distance = global_position.distance_to(enemy_pos)
		var distance = player_posi.distance_to(enemy_pos)
		if distance < shortest_distance:
			shortest_distance = distance
			closest_enemy_pos = enemy_pos
	
	var ray = RayCast2D.new()
	add_child(ray)

	ray.global_position = player_posi
	ray.target_position = closest_enemy_pos - player_posi  # relative direction
	ray.collision_mask = 1   # adjust to the layer your walls are on
	ray.enabled = true
	ray.force_raycast_update()
	print(ray, "ray")
	if ray.is_colliding():
		var collider = ray.get_collider()
		print(collider, "collider")
		if collider.has_method("enemy"):
			pass
		else:
			push_warning("Enemy blocked by obstacle")
			ray.queue_free()
			return


	ray.queue_free()

	
	
	# Calculate angle towards the closest enemy
	#var direction_vector = (closest_enemy_pos - global_position).normalized()
	var direction_vector = (closest_enemy_pos - player_posi).normalized()
	var angle_to_enemy = direction_vector.angle()

	# Instantiate and configure the projectile
	var projectile = projectile_path.instantiate()
	projectile.dir = angle_to_enemy
	#projectile.pos = global_position
	#projectile.pos = position
	projectile.pos = player_posi
	projectile.rota = angle_to_enemy
	get_parent().add_child(projectile)
	
	# logic to turn sprite in correct direction
	var dir_vector = direction_vector
	if abs(dir_vector.x) > abs(dir_vector.y):
		current_dir = "right" if dir_vector.x > 0 else "left"
	else:
		current_dir = "down" if dir_vector.y > 0 else "up"


	ranged_timer.start()
	can_shoot_projectile = false
	# for mobile phones, vibrate when shooting projectiles
	JavaScriptBridge.eval("navigator.vibrate(200);")
	
	Manager.projectile_count-=1
	ranged_count_label.text = str(Manager.projectile_count)
	shooting_projectile = true
	default_everything()
	play_anim(0)

func get_enemies_in_area() -> Array:
	var enemy_positions = []

	for body in projectile_detection.get_overlapping_bodies():
		#if body.is_in_group("enemies"):
		if body.has_method("enemy"):
			enemy_positions.append(body.global_position)

	return enemy_positions

func _process(delta: float) -> void:
	if Manager.player_is_alive:
		shake_strength = lerp(shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
		camera.offset = get_noise_offset(delta)

func _physics_process(delta):
	#print(get_enemies_in_area(), "enemies")
	if Manager.player_is_alive:
		shake_strength = lerp(shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
		camera.offset = get_noise_offset(delta)
		
		#debug stats
		debug_label.text = "cooldown " + str(attack_cooldown.time_left)
		debug_label.text += "\ncombo " + str(combo_timer.time_left)
		debug_label.text += "\ncan_attack " + str(can_attack)
		debug_label.text += "\nsecond_attack_pressed " + str(second_attack_pressed)
		debug_label.text += "\nthird_attack_pressed " + str(third_attack_pressed)
		debug_label.text += "\ncurrent_attack_anim " + str(current_attack_anim)
		debug_label.text += "\nprojectile_count " + str(Manager.projectile_count)

		ranged_bar.value = ((ranged_timer.wait_time - ranged_timer.time_left) / ranged_timer.wait_time) * 100
		if ranged_timer.is_stopped() :
			ranged_bar.value = 100
			
		if Manager.projectile_count <= 0:
			ranged_bar.value = 0
			
		player_movement(delta)
		#if !attack_ip:
			#hitbox_collisionshape.disabled = true
		#else:
			#hitbox_collisionshape.disabled = true

func fix_modulation():
	# to fix the modulation of character after he takes a hit
	player_sprite.material.set_shader_parameter("tint_color", Color(1, 1, 1, 1))
	player_sprite.self_modulate = Color.WHITE

func attack(dir):
	player_being_hit=false
	fix_modulation()
	
	my_hit_box.set_current_damage_name(current_attack_anim)
	
	if current_attack_anim == "melee_3":
		# for mobile phones, vibrate when third melee
		#apply_noise_shake()
		JavaScriptBridge.eval("navigator.vibrate(200);")
	
	if dir == "right":
		anim.play("side_" + current_attack_anim)
		
	if dir == "left":
		anim.play("side_" + current_attack_anim)

	if dir == "down":
		anim.play("front_" + current_attack_anim)

	if dir == "up":
		anim.play("back_" + current_attack_anim)

func default_everything():
	fix_modulation()
	player_being_hit = false
	hitbox_collisionshape.disabled = true
	attack_ip = false
	can_attack = true
	
	if timer_after_melee_3.time_left>0:
		can_attack = false
		
	can_second_attack = false
	second_attack_pressed = false
	can_third_attack = false
	third_attack_pressed = false
	current_attack_anim = "melee_1"
	my_hit_box.set_damage(damage_melee_1)

func player_movement(delta):
	var move_dir := Vector2.ZERO

	# Gather input
	if Input.is_action_pressed("right"):
		move_dir.x += 1
		current_dir = "right"
	elif Input.is_action_pressed("left"):
		move_dir.x -= 1
		current_dir = "left"
	
	if Input.is_action_pressed("down"):
		move_dir.y += 1
		current_dir = "down"
	elif Input.is_action_pressed("up"):
		move_dir.y -= 1
		current_dir = "up"

	# Normalize diagonal movement
	move_dir = move_dir.normalized()

	# Sprint logic
	var current_speed := speed
	var animation_index := 1  # 0 = idle, 1 = walk, 2 = sprint

	if Input.is_action_pressed("sprint"):
		current_speed = sprint_speed
		animation_index = 2

	# Apply velocity
	velocity = move_dir * current_speed

	# Animation logic
	if move_dir == Vector2.ZERO:
		play_anim(0)  # Idle
	else:
		play_anim(animation_index)


	#move_and_slide()
	move_and_collide(velocity)

func play_anim(movement):
	var dir = current_dir

	# Reset state if starting to move
	if movement == 1:
		default_everything()

	# Handle flipping for left/right
	player_sprite.flip_h = dir == "left"

	# Determine base animation name by direction
	var base_anim = ""

	match dir:
		"right", "left":
			base_anim = "side"
		"down":
			base_anim = "front"
		"up":
			base_anim = "back"
		_:
			base_anim = "side"  # fallback

	# Movement animations
	if movement == 2:
		anim.play(base_anim + "_run")
	elif movement == 1:
		anim.play(base_anim + "_walk")
	elif movement == 0:
		# Prioritize attack, ranged, hit, then idle
		if attack_ip:
			attack(dir)
		elif shooting_projectile:
			anim.play(base_anim + "_ranged")
		elif player_being_hit:
			anim.play(base_anim + "_hit")
		else:
			anim.play(base_anim + "_idle")

func take_player_damage(amount: float, enemy_position: Vector2, pushback_strength:float):
	_set_health(amount)
	player_being_hit = true
	print(amount, Manager.player_health, "damage done to player")

	# Calculate direction vector from enemy to player
	var dir_vector = (global_position - enemy_position).normalized()

	# Determine hit direction
	if abs(dir_vector.x) > abs(dir_vector.y):
		current_dir = "left" if dir_vector.x > 0 else "right"
	else:
		current_dir = "up" if dir_vector.y > 0 else "down"

	# Apply knockback (adjust the knockback_strength to your needs)
	#var knockback_strength = 15
	position += dir_vector * pushback_strength

func player():
	pass

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if "hit" in anim_name:
		player_being_hit = false
	
	if "ranged" in anim_name:
		shooting_projectile = false
	
	if "melee_1" in anim_name:
		if second_attack_pressed:
			current_attack_anim = "melee_2"
			my_hit_box.set_damage(damage_melee_2)
		else:
			attack_ip = false

	elif "melee_2" in anim_name:
		if third_attack_pressed:
			current_attack_anim = "melee_3"
			my_hit_box.set_damage(damage_melee_3)
		else:
			attack_ip = false
			current_attack_anim = "melee_1"
			second_attack_pressed = false
			third_attack_pressed = false

	elif "melee_3" in anim_name:
		attack_ip = false
		current_attack_anim = "melee_1"
		second_attack_pressed = false
		third_attack_pressed = false
		timer_after_melee_3.start()
		can_attack = false

func _on_attack_cooldown_timeout() -> void:
	can_attack = true
	can_second_attack = true
	can_third_attack = false
	if second_attack_pressed:
		can_third_attack = true
	combo_timer.start()

func _on_combo_timer_timeout() -> void:
	can_second_attack = false
	can_third_attack = false
	pass # Replace with function body.

func _on_ranged_timer_timeout() -> void:
	can_shoot_projectile = true

func _on_timer_after_melee_3_timeout() -> void:
	can_attack = true
