extends Node2D

@export var max_boulder_health = 200
@export var player_damage_good = 20
@export var player_damage_perfect = 40

var game_won = false
var combo_stage: int = 1
var max_hits = 5
var current_hits = 0
var cur_boulder_health = max_boulder_health
@onready var my_sprite = $StaticBody2D2/Sprite2D
@onready var big: CPUParticles2D = $StaticBody2D2/Sprite2D/particles/big
@onready var medium: CPUParticles2D = $StaticBody2D2/Sprite2D/particles/medium
@onready var small: CPUParticles2D = $StaticBody2D2/Sprite2D/particles/small



signal request_scene_change(world_name: String, spawn_point: String, is_speaking_scene: bool, dialogue_path: String, next_scene: String)

func next_scene():
	request_scene_change.emit("trial_of_lights_6", "SpawnPoint1", true, "res://dialogues/test_dialogue_1.dialogue")  # Or whatever scene you want



func generate_noise_texture(size := 256) -> ImageTexture:
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.05
	noise.fractal_octaves = 4
	noise.fractal_gain = 0.5
	noise.fractal_lacunarity = 2.0

	var img = Image.create(size, size, false, Image.FORMAT_RF)

	for y in size:
		for x in size:
			var value = noise.get_noise_2d(x, y) * 0.5 + 0.5
			img.set_pixel(x, y, Color(value, 0, 0))

	var tex = ImageTexture.create_from_image(img)
	return tex



func set_sprite_frame_from_path(sprite: Sprite2D, image_path: String, frame_count: int, frame_index: int) -> void:
	if frame_index < 0 or frame_index >= frame_count:
		push_error("Frame index out of bounds!")
		return

	# Load the texture from the file path
	var texture := load(image_path)
	if not texture or not texture is Texture2D:
		push_error("Failed to load texture from path: " + image_path)
		return

	# Get the size of the entire texture
	var atlas_size = texture.get_size()
	var frame_width = atlas_size.x / frame_count
	var frame_height = atlas_size.y

	# Assign the texture to the sprite
	sprite.texture = texture
	sprite.region_enabled = true
	sprite.region_rect = Rect2(
		Vector2(frame_width * frame_index, 0),
		Vector2(frame_width, frame_height)
	)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cur_boulder_health = max_boulder_health
	
	my_sprite.material.set_shader_parameter("fade_amount", 0.0)
	
	$Player.connect("reached_target", Callable(self, "_on_player_arrived"))
	$CanvasLayer/timing_bar.connect("bar_hit", _bar_hit)
	
	var noise_tex = generate_noise_texture()
	my_sprite.material.set_shader_parameter("noise_tex", noise_tex)
	
	#set_sprite_frame_from_path(my_sprite, "res://assets/characters/minigame_assets/timing_bar/boulder.png", 5, 4)  # Show frame 1 of 4

func play_player_attack_anim():
	var anim_name = "back_melee_%d" % combo_stage
	
	$CanvasLayer/timing_bar.can_hit = false
	$Player.anim.play(anim_name)
	big.emitting = true
	medium.emitting = true
	small.emitting = true

	await $Player.anim.animation_finished
	$CanvasLayer/timing_bar.can_hit = true
	$Player.anim.play("back_idle")

	# Advance combo if not already at the last stage
	if combo_stage < 3:
		combo_stage += 1

func game_lost():
	$CanvasLayer/timing_bar.game_done()
	$CanvasLayer/timing_bar.can_hit = false	
	var tween := create_tween()
	var timing_bar := $CanvasLayer/timing_bar

	# Start tweening the alpha from current value to 0 over 2 seconds
	tween.tween_property(
		timing_bar,
		"modulate:a",  # Target the alpha channel of the Color
		0.0,           # Final alpha value
		1.5           # Duration in seconds
	)
	await tween.finished
	await get_tree().create_timer(1).timeout
	$Player.death_player("max_hits_reached")


func on_boulder_destroyed():
	var tween = create_tween()
	tween.tween_property(my_sprite.material, "shader_parameter/fade_amount", 1.0, 1.0)  # Fade out over 2 seconds
	await tween.finished
	$StaticBody2D2/CollisionShape2D.disabled = true
	$Player.is_movement_paused = false
	$CanvasLayer.visible = false
	$Player/canvas_hud/touch_controls.visible = true
	game_won = true

func _bar_hit(hit_name):
	print(hit_name)
	current_hits +=1
	if current_hits>=max_hits:
		game_lost()
	match hit_name:
		"perfect":
			cur_boulder_health -= player_damage_perfect
			await play_player_attack_anim()
		"good":
			cur_boulder_health -= player_damage_good
			await play_player_attack_anim()
		"miss":
			combo_stage = 1  # Reset combo on miss
			return  # No damage, skip rest of logic

	cur_boulder_health = clamp(cur_boulder_health, 0, max_boulder_health)
	if cur_boulder_health <= 0:
		on_boulder_destroyed()
		return
	
	var health_percent = float(cur_boulder_health) / float(max_boulder_health)

	var frame_index := 0
	if health_percent <= 0.2:
		frame_index = 4
	elif health_percent <= 0.4:
		frame_index = 3
	elif health_percent <= 0.6:
		frame_index = 2
	elif health_percent <= 0.8:
		frame_index = 1

	set_sprite_frame_from_path(
		my_sprite,
		"res://assets/characters/minigame_assets/timing_bar/boulder.png",
		5,
		frame_index
	)
	

func _on_player_arrived():
	print("Player has arrived at the destination!")
	$Player.is_movement_paused = true
	$CanvasLayer.visible = true
	$Player/canvas_hud/touch_controls.visible = false
	
#func start_timing_bar():
	#$Player.is_movement_paused = true
	#

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _physics_process(delta: float) -> void:
	##if not player_anim_playing:
		##$Player.anim.play("back_idle")
	#pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("player") and not game_won:
		$Player.move_player_to_position(Vector2(245, 380), "up")
		#start_timing_bar()
