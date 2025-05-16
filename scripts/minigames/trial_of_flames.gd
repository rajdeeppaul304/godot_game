extends Node2D

#@onready var animation_player: AnimationPlayer = $torches/AnimationPlayer
@onready var torches: Node2D = $torches
var torch_sprites: Array = []
var correct_sequence: Array = [2, 5, 1, 6, 4, 8, 3, 7]  # Your sequence
var current_index: int = 0
var max_tries = 10
var cur_tries = 0
var game_won = false
var game_lost = false

@onready var animation_player: AnimationPlayer = $Sprite2D2/AnimationPlayer
@onready var shader_material := $Node2D/Sprite2D.material as ShaderMaterial
@onready var tween_door := create_tween()
@onready var sprite_2d: Sprite2D = $Node2D/Sprite2D
@onready var dragon_ball_collision_shape: CollisionShape2D = $Item/CollisionShape2D
@onready var dragon_ball: Area2D = $Item


signal request_scene_change(world_name: String, spawn_point: String, is_speaking_scene: bool, dialogue_path: String, next_scene: String)

func next_scene():
	request_scene_change.emit("last_level_part_1", "spawnpoint1", true, "res://dialogues/test_dialogue_1.dialogue")  # Or whatever scene you want
	

func summon_ball():
	dragon_ball.visible = true
	dragon_ball_collision_shape.disabled = false
	var tween := create_tween()

	$Player.apply_noise_shake()
	tween.tween_property(sprite_2d.material, "shader_parameter/fade", 1.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _game_lost():
	$Player.is_movement_paused = true
	await get_tree().create_timer(1).timeout
	$Player.death_player("too_many_attempts")

func apply_random_cloud_styles(cloud_sprites: Array[Sprite2D]) -> void:
	# old colors
	#var modulate_colors = [
		#Color("#D0E0FF"),  # Cool Mist Blue
		#Color("#C0A0FF"),  # Purple Shadow
		#Color("#FFF0CC"),  # Sunlit Cream
		#Color("#B8B0C8"),  # Soft Grey-Lavender
		#Color("#D08090")   # Dusky Rose
	#]
	
	var modulate_colors = [
		Color("#A0C8F8"),  # Soft Sky Blue — keep one blue for cool contrast
		Color("#D0A0F0"),  # Orchid Purple — whimsical and magical
		Color("#B0F0D0"),  # Mint Green — fresh and ethereal
		Color("#F0A8A8"),  # Coral Rose — warm but vivid, stands out
		Color("#F8F090")   # Pale Lemon — very bright, dreamlike contrast
	]


	for cloud in cloud_sprites:
		if cloud is Sprite2D:
			# Random scale between 0.5 and 1.5
			var scale_factor := randf_range(0.5, 1.5)
			cloud.scale = Vector2(scale_factor, scale_factor)
			
			# Random modulate color with fixed alpha of 0.8
			var chosen_color = modulate_colors[randi() % modulate_colors.size()]
			chosen_color.a = 0.8
			cloud.modulate = chosen_color

func get_parallax_sprites_except_sky(parallax_bg: ParallaxBackground) -> Array[Sprite2D]:
	var sprites: Array[Sprite2D] = []

	for layer in parallax_bg.get_children():
		if layer is ParallaxLayer:
			for child in layer.get_children():
				if child is Sprite2D and child.name != "sky_bg":
					sprites.append(child)

	return sprites

func _ready() -> void:
	dragon_ball.visible = false
	dragon_ball_collision_shape.disabled = true
	randomize()
	var cloud_sprites = get_parallax_sprites_except_sky($Node2D/ParallaxBackground)
	apply_random_cloud_styles(cloud_sprites)
	
	
	for i in range(1, 9):  # torch indices from 1 to 8
		var static_body = torches.get_node_or_null("StaticBody2D%d" % i)
		if static_body:
			var sprite = static_body.get_node_or_null("Sprite2D1")
			if sprite and sprite is Sprite2D:
				torch_sprites.append(sprite)
				# Connect the signal with index as a bound argument
				sprite.connect("toggled", Callable(self, "_on_torch_toggled").bind(i))
			else:
				push_warning("❌ Sprite2D%d not found under StaticBody2D%d" % [i, i])
		else:
			push_warning("❌ StaticBody2D%d not found" % i)

	print("🔥 Loaded torch sprites:", torch_sprites.size())


func _on_torch_toggled(torch_index: int) -> void:
	#vanish_door()
	if not game_won and not game_lost:
		var expected_index = correct_sequence[current_index]
		cur_tries+=1
		if cur_tries>=max_tries:
			game_lost = true
			_game_lost()
			return
		if torch_index == expected_index:
			print("✅ Correct torch", torch_index)
			current_index += 1

			if current_index >= correct_sequence.size():
				game_won = true
				print("🎉 Puzzle complete!")
				#animation_player.play("open_door")
				summon_ball()
		else:
			print("❌ Wrong torch", torch_index, "Expected:", expected_index)
			reset_torches()


func reset_torches() -> void:
	for sprite in torch_sprites:
		sprite.turn_off()
	current_index = 0
	print("🔄 Torches reset")
