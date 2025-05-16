class_name Player
extends CharacterBody2D

@export var projectile_tex : Texture2D
@export_enum("dragon_ball_1", "dragon_ball_2", "dragon_ball_3", "dragon_ball_4", "dragon_ball_5", "dragon_ball_6", "dragon_ball_7")
var current_ball: String
# items picked by Player
#@export var projectile_count:int = 100
#@export var health_potion_count:int = 100


@export var damage_melee_1:float = 10
@export var damage_melee_2:float = 15
@export var damage_melee_3:float = 20
@export var projectile_knockback = 10


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

@export var speed := 2.0
@export var sprint_speed := 3.0
var current_dir = "right"

var enemy_in_attack_range = false
var enemies_in_range = 0
var enemy_attack_cooldown = true
#var health:float
var player_alive = true
var player_being_hit = false
var direction_stack := []

# pause inputs
var is_movement_paused = false
var is_attack_paused = false
var is_projectile_paused = false


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

var moving_to_position := false  # Flag to block movement logic


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
@onready var skip_button: Button = $canvas_hud/skip_button

signal player_registered(player_ref: CharacterBody2D)

func item_picked(item_name):
	if item_name == "HealthPotion":
		Manager.health_potion_count += 1
		health_potion_count_label.text = str(Manager.health_potion_count)
	elif item_name == "Projectile":
		Manager.projectile_count += 1
		ranged_count_label.text = str(Manager.projectile_count)
	elif item_name.begins_with("dragon_ball_"):
		if get_parent().has_method("next_scene"):
			get_parent().next_scene()
		else:
			assert(false,get_parent().name + "world scene doesnt have next_scene")


func apply_noise_shake() -> void:
	shake_strength = NOISE_SHAKE_STRENGTH

func get_noise_offset(delta: float) -> Vector2:
	noise_i += delta * NOISE_SHAKE_SPEED
	return Vector2(
		noise.get_noise_2d(1.0, noise_i) * shake_strength,
		noise.get_noise_2d(100.0, noise_i) * shake_strength
	)


func update_dragon_balls(current_ball: String):
	var ball_states = Manager.ball_states

	for child in $canvas_hud/Dragon_Balls.get_children():
		if not child is CanvasItem:
			continue
		
		var ball_name = child.name
		if not ball_states.has(ball_name):
			continue

		var state = ball_states[ball_name]

		match state:
			Manager.BallState.NOT_COLLECTED:
				child.modulate = Color(0.5, 0.5, 0.5)  # Greyed out
			Manager.BallState.SKIPPED:
				child.modulate = Color(0.5, 0.5, 1.0)  # Blueish
			Manager.BallState.COLLECTED:
				child.modulate = Color(1, 1, 1)  # No modulate

		# If this is the current ball, override with green and animate
		if ball_name == current_ball:
			var tween = child.create_tween()
			tween.set_loops()

			# No modulate means it will have the default color, which is effectively no color adjustment
			var original_color = Color(1.0, 1.0, 1.0)  # No modulate (original color)
			
			# Target color - soft pinkish hue (#e8ace9)
			var glow_color = Color(0.91, 0.67, 0.91)  # RGB equivalent of #e8ace9

			# Set to no modulate (original color)
			child.modulate = original_color

			# Tween the modulate color to a soft pink and back to original
			tween.tween_property(child, "modulate", glow_color, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(child, "modulate", original_color, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)



func _ready():
	
	#camera = get_parent()
	
	if Manager.player_is_alive:
		assert(current_ball != "", "Error: 'current_ball' is not set in the inspector for this scene.")
		update_dragon_balls(current_ball)

		Manager.current_player_info
		player_sprite.texture = load(Manager.current_player_info["sprite_location"])
		
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
		my_hit_box.set_knockback(5.0)
		
		rand.randomize()
		noise.seed = rand.randi()
		noise.frequency = 0.5  # Lower frequency = smoother noise (similar to period in OpenSimplexNoise)
		noise.noise_type = FastNoiseLite.TYPE_SIMPLEX  # You can try TYPE_PERLIN or others too

		#hitbox_collisionshape.disabled = true
	

#func show_dialogue_with_transition():
	#var dialogue_scene = load("res://scenes/menu/character_speaking.tscn").instantiate()
	#dialogue_scene.dialogue_file_location = "res://dialogues/test_dialogue_1.dialogue"
	#dialogue_scene.next_scene_file = "res://scenes/world3.tscn"
	#get_tree().current_scene.add_child(dialogue_scene)

func _input(event: InputEvent) -> void:

	
	#if Input.is_action_just_pressed("attack"):
		#show_dialogue_with_transition()
		
	if Manager.player_is_alive:
		
		if event is InputEventKey:
			var dir := ""
			match event.physical_keycode:
				KEY_RIGHT:
					dir = "right"
				KEY_LEFT:
					dir = "left"
				KEY_DOWN:
					dir = "down"
				KEY_UP:
					dir = "up"

			if dir != "":
				if event.pressed and not event.echo:
					direction_stack.erase(dir)
					direction_stack.append(dir)
				elif not event.pressed:
					direction_stack.erase(dir)
				
		if Input.is_action_just_pressed("attack"):
			if !is_attack_paused:
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
			if (can_shoot_projectile == true) and (Manager.projectile_count>0) and !is_projectile_paused:
				shoot_projectile()
		
		if Input.is_action_just_pressed("health_potion"):
			drink_health_potion()

func _set_health(amount:float, kill_type="death_by_enemy"):
	Manager.player_health += amount
	if Manager.player_health<=0:
		Manager.player_health = 0
		
	health_bar.value = Manager.player_health
	
	if Manager.player_health <= 0 :
		death_player(kill_type)
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


func hide_hud_touch_controls(hud:bool = true, touch_controls:bool=true):
	if hud == true:
		$canvas_hud.visible = false
	if touch_controls == true:
		$canvas_hud/touch_controls.visible = false
		
func show_hud_touch_controls(hud:bool = true, touch_controls:bool=true):
	if hud == true:
		$canvas_hud.visible = true
	if touch_controls == true:
		$canvas_hud/touch_controls.visible = true


func death_player(reason="death_by_enemy"):
	Manager.player_is_alive = false
	#death_screen
	#if reason != "":
		#get_parent().reset_level("fell_off_crack")
	if reason in  ["death_by_enemy", "death_by_arrow", "moves_exhausted", "failed_sequence_challenge", "time_expired", "max_hits_reached", "too_many_attempts"]:
		var noise_texture = generate_noise_texture()
		player_sprite.material.set_shader_parameter("noise_tex", noise_texture)
		
		var mat = player_sprite.material
		#
		var tween = create_tween()
		tween.tween_property(mat, "shader_parameter/progress", 1.0, 2)

		tween.parallel().tween_property(player_sprite, "modulate:a", 0.0, 2)

		
		await tween.finished
		
	
	var death_screen_instance =  death_screen.instantiate()
	death_screen_instance.reason = reason
	
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
	
	projectile.my_hit_box.set_knockback(projectile_knockback)
	
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
	
	if !is_projectile_paused:
		Manager.projectile_count-=1
		ranged_count_label.text = str(Manager.projectile_count)
		default_everything()

	shooting_projectile = true

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
	#print($player_hurtbox/CollisionShape2D.disabled)
	#print(get_enemies_in_area(), "enemies")
	if Manager.player_is_alive:
		#print(Manager.ball_states)
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
		
		if moving_to_position:
			play_anim(1)
		
		#if !attack_ip:
			#hitbox_collisionshape.disabled = true
		#else:
			#hitbox_collisionshape.disabled = true

func fix_modulation():
	# to fix the modulation of character after he takes a hit
	player_sprite.material.set_shader_parameter("tint_color", Color(1, 1, 1, 1))
	player_sprite.self_modulate = Color.WHITE

func attack(dir):
	if !is_attack_paused:

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
	#if is_movement_paused:
		#velocity = Vector2.ZERO
		#play_anim(0)
		#return
	
	if is_movement_paused or moving_to_position:
		velocity = Vector2.ZERO
		#play_anim(0)
		return


	var move_dir := Vector2.ZERO
	var current_speed = speed
	var animation_index := 1

	if Input.is_action_pressed("sprint"):
		current_speed = sprint_speed
		animation_index = 2

	if direction_stack.size() > 0:
		var current_direction = direction_stack[-1]  # Most recent pressed
		match current_direction:
			"right":
				move_dir.x = 1
			"left":
				move_dir.x = -1
			"down":
				move_dir.y = 1
			"up":
				move_dir.y = -1
		current_dir = current_direction

	move_dir = move_dir.normalized()
	velocity = move_dir * current_speed

	if move_dir == Vector2.ZERO:
		play_anim(0)
	else:
		play_anim(animation_index)

	move_and_collide(velocity)

func play_walk(dir):
	var base_anim = "left"
	anim.play(base_anim + "_walk")
	
	
func flash_effect() -> void:
	var flash_effect_total_time := 0.5
	var flash_effect_wait := 0.05
	
	var val_visible := Color(1, 1, 1, 1)    # Fully visible white
	var val_invisible := Color(1, 1, 1, 0)  # Transparent white
	
	var toggle := true
	var elapsed := 0.0
	
	while elapsed < flash_effect_total_time:
		var from_color : Color
		var to_color : Color
		
		if toggle:
			from_color = val_invisible
			to_color = val_visible
		else:
			from_color = val_visible
			to_color = val_invisible
		
		toggle = !toggle

		var tween := create_tween()
		tween.tween_property(player_sprite.material, "shader_parameter/tint_color", to_color, flash_effect_wait).from(from_color)
		await tween.finished
		
		elapsed += flash_effect_wait




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
		#elif player_being_hit:
			#anim.play(base_anim + "_hit")
		else:
			anim.play(base_anim + "_idle")

signal reached_target

func _on_reach_target_direction(end_facing_direction: String) -> void:
	current_dir = end_facing_direction
	moving_to_position = false
	is_movement_paused = false
	play_anim(0)  # Switch to idle facing final direction
	emit_signal("reached_target")


func move_player_to_position(target_position: Vector2, end_facing_direction: String, move_speed := 100.0) -> void:
	is_movement_paused = true
	moving_to_position = true

	var walk_dir := (target_position - global_position).normalized()

	# Set direction for animation
	if abs(walk_dir.x) > abs(walk_dir.y):
		current_dir = "right" if walk_dir.x > 0 else "left"
	else:
		current_dir = "down" if walk_dir.y > 0 else "up"

	play_anim(1)  # Start walking animation manually

	var tween := create_tween()
	var distance := global_position.distance_to(target_position)
	var duration := distance / move_speed
	
	tween.tween_property(self, "global_position", target_position, duration)
	tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.connect("finished", Callable(self, "_on_reach_target_direction").bind(end_facing_direction))
	


# always give damage amount in negatve
func take_player_damage(amount: float, enemy_position: Vector2, pushback_strength: float, kill_type="death_by_enemy"):
	_set_health(amount, kill_type)
	player_being_hit = true
	print(amount, Manager.player_health, "damage done to player")
	flash_effect()
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


func _on_skip_button_pressed() -> void:
	$canvas_hud/skip_panel_confirm.visible = true


func _on_skip_not_confirm_pressed() -> void:
	$canvas_hud/skip_panel_confirm.visible = false

func _on_skip_confirm_pressed() -> void:
	Manager.skip_ball(current_ball)
	$canvas_hud/skip_panel_confirm.visible = false
	if get_parent().has_method("next_scene"):
		get_parent().next_scene()
	else:
		assert(false,get_parent().name + "world scene doesnt have next_scene")
