extends Node2D

@export var arrow_scene_file: PackedScene = load("res://scripts/enemy/arrow_projectile_enemy.tscn")
@export var speed: float = 200.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var raycasts: Array[RayCast2D] = [$RayCast2D_1, $RayCast2D_2, $RayCast2D_3]
@onready var raycasts2: Array[RayCast2D] = [$RayCast2D_4, $RayCast2D_5, $RayCast2D_6]
@onready var sprite_2d_3: Sprite2D = $Sprite2D3

var can_shoot: bool = true
var player_detected: bool = false
@export var shoot_direction: String = "right" # Default direction, could be dynamic
var shot_type
var detected_raycast: RayCast2D = null


func _rotate_rays_for_left():
	for raycast in raycasts + raycasts2:
		raycast.rotation_degrees += 180
		var pos = raycast.position
		pos.x = -pos.x
		raycast.position = pos

func _flip_sprites_for_left():
	for child in get_children():
		if child is Sprite2D:
			child.flip_h = true
			var pos = child.position
			pos.x = -pos.x
			child.position = pos

func _ready():
	sprite_2d_3.visible = false
	#if "left" in name:
		#shoot_direction = "left"
	if shoot_direction == "left":
		_rotate_rays_for_left()
		_flip_sprites_for_left()

func _process(delta: float) -> void:
	
	if not Manager.player_is_alive:
		animation_player.play("idle")
		#return
	else:
		if can_shoot:
			var player_was_detected = false

			for raycast in raycasts:
				if raycast.is_colliding():
					var collider = raycast.get_collider()
					if collider and collider.has_method("player"):
						player_detected = true
						shot_type = 1
						detected_raycast = raycast
						player_was_detected = true
						break

			if not player_detected:
				for raycast2 in raycasts2:
					if raycast2.is_colliding():
						var collider = raycast2.get_collider()
						if collider and collider.has_method("player"):
							player_detected = true
							shot_type = 2
							detected_raycast = raycast2
							player_was_detected = true
							break

			# Play idle animation and show only Sprite2D4 when idle
			if not player_was_detected:
				if not animation_player.is_playing() or animation_player.current_animation != "idle":
					animation_player.play("idle")

				# Show only idle sprite
				$Sprite2D.visible = false
				$Sprite2D2.visible = false
				$Sprite2D3.visible = false
				$Sprite2D4.visible = true

			if player_detected and detected_raycast:
				can_shoot = false
				player_detected = false
				$Sprite2D4.visible = false # Hide idle sprite

				if shot_type == 1:
					$Sprite2D.visible = true
					$Sprite2D2.visible = false
					animation_player.play("shot_1")
				elif shot_type == 2:
					$Sprite2D2.visible = true
					$Sprite2D.visible = false
					animation_player.play("shot_2")


func shoot_arrow():
	var arrow = arrow_scene_file.instantiate()
	
	if detected_raycast:
		arrow.global_position = detected_raycast.global_position
	else:
		arrow.global_position = global_position # fallback
	
	arrow.speed = speed
	arrow.direction = shoot_direction
	add_sibling(arrow)
	arrow.shoot()

	detected_raycast = null # Reset for next shot



func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	#print("animation finished")
	if anim_name == "shot_1":
		shoot_arrow()
		animation_player.play("after_shot_1")
		await get_tree().create_timer(0.4).timeout # Cooldown before next shot
		can_shoot = true
	elif anim_name == "shot_2":
		shoot_arrow()
		animation_player.play("after_shot_2")
		await get_tree().create_timer(0.4).timeout # Cooldown before next shot
		can_shoot = true
