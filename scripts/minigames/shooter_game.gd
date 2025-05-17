extends Node2D
@onready var area_2d: Area2D = $Area2D
#var player_entered = true
@onready var camera_2d: Camera2D = $Player/Camera2D
@onready var marker_2d: Marker2D = $Marker2D
@onready var enemy: CharacterBody2D = $Enemy

# Called when the node enters the scene tree for the first time.
#@onready var label: Label = $CanvasLayer/Label
@onready var result_label: Label = $CanvasLayer/ResultLabel
@onready var panel_with_keys: Panel = $CanvasLayer/Panel
@onready var animation_player: AnimationPlayer = $CanvasLayer/AnimationPlayer

@onready var texture_rect_3: TextureRect = $CanvasLayer/Panel/GridContainer/TextureRect3
@onready var texture_rect_4: TextureRect = $CanvasLayer/Panel/GridContainer/TextureRect4
@onready var texture_rect_5: TextureRect = $CanvasLayer/Panel/GridContainer/TextureRect5
@onready var texture_rect_6: TextureRect = $CanvasLayer/Panel/GridContainer/TextureRect6
@onready var texture_rect_7: TextureRect = $CanvasLayer/Panel/GridContainer/TextureRect7

signal request_scene_change(world_name: String, spawn_point: String, is_speaking_scene: bool, dialogue_path: String, next_scene: String)

func next_scene():
	request_scene_change.emit("sliding_puzzle_4", "SpawnPoint1", true, "res://dialogues/test_dialogue_1.dialogue")  # Or whatever scene you want
	

func update_prompt_progress(current_round: int) -> void:
	print(current_round)
	var fill_region := Rect2(6, 0, 6, 6)
	var default_region := Rect2(0, 0, 6, 6)

	var atlas_image := preload("res://assets/characters/small_circle_light.png")  # Replace with your actual atlas

	var texture_rects := [
		texture_rect_3,
		texture_rect_4,
		texture_rect_5,
		texture_rect_6,
		texture_rect_7
	]

	for i in texture_rects.size():
		var tex_rect = texture_rects[i]

		var atlas_tex := AtlasTexture.new()
		atlas_tex.atlas = atlas_image

		if i < current_round:
			atlas_tex.region = fill_region
		else:
			atlas_tex.region = default_region

		tex_rect.texture = atlas_tex




const POSSIBLE_ACTIONS := ["attack", "sprint", "projectile_1", "health_potion"]
const SEQUENCE_LENGTH := 5
const INPUT_TIME := 5  # Seconds to press each input


var qte_sequence := []
var current_index := 0
var qte_active := false
var input_timer : Timer

@export var MAX_ATTEMPTS := 5
@export var REQUIRED_SUCCESSES := 3

# Track progress
var attempts := 0
var successes := 0
var game_started = false
var game_done = false

func move_camera():
	game_started=true
	$Player.ranged_count_label.text = "∞"
	
	$Player.is_movement_paused = true
	$Player.play_anim(0)
	$Player.is_attack_paused = true
	$Player.is_projectile_paused = true
	
	$Player.projectile_knockback = 0
	#$Player.ranged_timer.wait_time = 0.2
	var shape = $Player/projectile_detection/CollisionShape2D.shape
	if shape is CircleShape2D:
		shape.radius = 400  # Change this value to whatever you want
	
	var tween := create_tween()
	tween.tween_property(camera_2d, "global_position", marker_2d.global_position, 1.0) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)

	tween.finished.connect(_on_tween_finished)

func _physics_process(delta: float) -> void:
	if not game_done and game_started:
		$Player.play_anim(0)
	pass
	
	
func _ready():
	$Enemy.health_bar2.visible = false
	panel_with_keys.visible = false
	input_timer = Timer.new()
	input_timer.wait_time = INPUT_TIME
	input_timer.one_shot = true
	input_timer.timeout.connect(_on_input_timeout)
	add_child(input_timer)

func _on_tween_finished():
	
	start_qte_round()

func start_qte_round():
	if attempts >= MAX_ATTEMPTS:
		end_qte_challenge()
		return

	qte_active = true
	current_index = 0
	result_label.text = ""
	attempts += 1
	
	qte_sequence.clear()
	for i in SEQUENCE_LENGTH:
		qte_sequence.append(POSSIBLE_ACTIONS[randi() % POSSIBLE_ACTIONS.size()])
	show_next_prompt()

func show_next_prompt():
	if current_index >= qte_sequence.size():
		qte_success()
		return
		
	update_prompt_progress(current_index + 1) 
	
	panel_with_keys.visible = true
	animation_player.stop()
	animation_player.play(qte_sequence[current_index])
	
	
	input_timer.start()

func _on_input_timeout():
	if game_done:
		return
	panel_with_keys.visible = false
	qte_fail("Too Slow!")

func _unhandled_input(event):
	if not qte_active or not event.is_pressed():
		return

	if event is InputEventMouseButton or event is InputEventScreenTouch:
		return

	var current_action = qte_sequence[current_index]
	for action in POSSIBLE_ACTIONS:
		if Input.is_action_just_pressed(action):
			if action == current_action:
				current_index += 1
				input_timer.stop()
				show_next_prompt()
			else:
				qte_fail("Wrong Button!")
			break

func qte_success():
	panel_with_keys.visible = false
	qte_active = false
	successes += 1
	#label.text = ""
	#result_label.text = "QTE SUCCESS! (%d/%d)" % [successes, MAX_ATTEMPTS]
	result_label.text = "SUCCESSFUL HIT!"
	$Player.shoot_projectile()
	#$Player.anim.play("side_ranged")
	$Player.play_anim(0)
	
	await get_tree().create_timer(2).timeout
	start_qte_round()

func qte_fail(reason: String):
	panel_with_keys.visible = false
	qte_active = false
	#label.text = ""
	#result_label.text = "QTE FAILED: " + reason + " (%d/%d)" % [successes, MAX_ATTEMPTS]
	result_label.text = "FAILED: " + reason 

	await get_tree().create_timer(2).timeout
	start_qte_round()

func end_qte_challenge():
	#label.text = ""
	panel_with_keys.visible = false
	if successes >= REQUIRED_SUCCESSES:
		final_qte_success()
	else:
		final_qte_fail()

func final_qte_success():
	# Reset label visuals
	result_label.modulate = Color(0, 1, 0, 0)  # Start transparent green
	result_label.scale = Vector2(0.5, 0.5)  # Slightly smaller
	result_label.text = "FINAL RESULT: SUCCESS!"
	if enemy:
		$Enemy/EnemyStateMachine._transition_to_next_state("Death")
		
	var tween := create_tween()
	tween.tween_property(result_label, "modulate:a", 1.0, 0.4) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(result_label, "scale", Vector2(1, 1), 0.4) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Delay, then fade out after 2 seconds
	tween.tween_interval(2.0)
	tween.tween_property(result_label, "modulate:a", 0.0, 0.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Game logic
	$Player.is_movement_paused = false
	$Player.is_attack_paused = false
	$Player.is_projectile_paused = false
	$Player.projectile_knockback = 10
	game_done = true


		#enemy.queue_free()



#func final_qte_success():
	#
	#result_label.text = "FINAL RESULT: SUCCESS!"
	#$Player.is_movement_paused = false
	#$Player.is_attack_paused = false
	#$Player.is_projectile_paused = false
	#
	#$Player.projectile_knockback = 10
	#game_done = true
	#if enemy:
		#enemy.queue_free()
	
	# Unlock something, continue story, etc.

func final_qte_fail():
	game_done = true
	result_label.text = "FINAL RESULT: FAILURE!"
	await get_tree().create_timer(2.5).timeout
	result_label.visible = false
	$Player.death_player("failed_sequence_challenge")
	# Apply consequences

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		if !game_done:
			move_camera()
