extends Node2D

@onready var background: TextureRect = $backgroun
@onready var goodzone_area: Area2D = $backgroun/goodzone/Area2D
@onready var perfectzone_area: Area2D = $backgroun/perfectzone/Area2D
@onready var marker: TextureRect = $backgroun/marker
@onready var marker_area: Area2D = $backgroun/marker/Area2D

@onready var inside_bg: TextureRect = $backgroun/inside_bg

const feedback_image  = preload("res://assets/characters/minigame_assets/text_prompts.png")

signal bar_hit(hit_name:String)

var base_speed = 100
var speed = base_speed
var acceleration = 50.0
var direction = 1

# controlled by top level
var can_hit = true


func _ready():
	# Make sure marker Area2D is monitoring
	marker_area.monitoring = true
	marker_area.monitorable = true

func _process(delta):
	input_handled_this_frame = false  # Reset for the next frame

	speed += acceleration * delta

	var new_y = marker.position.y + direction * speed * delta

	var marker_half_height = marker.size.y / 2

	# Calculate bounds relative to inside_bg
	var top_y = inside_bg.position.y
	var bottom_y = inside_bg.position.y + inside_bg.size.y - marker.size.y

	var clamped_y = clamp(new_y, top_y, bottom_y)

	# Reverse direction if hitting top/bottom
	if clamped_y != new_y:
		direction *= -1
		speed = base_speed

	marker.position.y = clamped_y

var input_handled_this_frame := false

#func _unhandled_input(event):
	#if input_handled_this_frame:
		#return  # Already handled one input this frame
#
	#if event.pressed:
		#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			#check_hit()
			#input_handled_this_frame = true
		#elif event is InputEventScreenTouch:
			#check_hit()
			#input_handled_this_frame = true

#func _unhandled_input(event):
	#if input_handled_this_frame or not can_hit:
		#return  # Already handled one input this frame
#
	#if event is InputEventMouseButton:
		#if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			#check_hit()
			#input_handled_this_frame = true
			#
	#elif event is InputEventScreenTouch:
		#if event.pressed:
			#check_hit()
			#input_handled_this_frame = true
#func _process(delta):
	#input_handled_this_frame = false  # Reset for the next frame


func show_floating_feedback(type: String, position: Vector2):
	var sprite := Sprite2D.new()

	# Create AtlasTexture
	var atlas := AtlasTexture.new()
	atlas.atlas = feedback_image

	match type:
		"MISS":
			atlas.region = Rect2(Vector2(0, 0), Vector2(32, 16))
		"GOOD":
			atlas.region = Rect2(Vector2(32, 0), Vector2(32, 16))
		"PERFECT":
			atlas.region = Rect2(Vector2(64, 0), Vector2(48, 16))
		_:
			return # unknown type

	sprite.texture = atlas
	sprite.z_index = 10
	sprite.global_position = position
	#sprite.scale = Vector2(10,10)
	add_child(sprite)
	#marker.add_child(sprite)

	# Animate like before
	sprite.scale = Vector2(5, 5)  # Start scale

	var tween = get_tree().create_tween()

	# Step 1: Pop up to 10x scale quickly
	tween.tween_property(sprite, "scale", Vector2(10, 10), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Step 2: Settle to 8x scale
	tween.tween_property(sprite, "scale", Vector2(8, 8), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Step 3: Wait a bit (at final scale)
	tween.tween_interval(0.4)

	# Step 4: Fade out and float up
	tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
	tween.tween_property(sprite, "position", sprite.position + Vector2(0, -20), 0.3)

	# Step 5: Free after done
	tween.tween_callback(Callable(sprite, "queue_free"))

func check_hit():
	var overlaps = marker_area.get_overlapping_areas()
	var spawn_point = marker.global_position + Vector2(marker.size.x / 2 + 300, 0)

	if perfectzone_area in overlaps:
		print("🎯 PERFECT!")
		bar_hit.emit("perfect")
		show_floating_feedback("PERFECT", spawn_point)
		

	elif goodzone_area in overlaps:
		print("👍 GOOD!")
		bar_hit.emit("good")
		show_floating_feedback("GOOD", spawn_point)

	else:
		print("❌ MISS!")
		bar_hit.emit("miss")
		#show_floating_feedback("MISS", Vector2(0,0))

		show_floating_feedback("MISS", spawn_point)

	# Reset speed after input
	speed = base_speed

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		_on_button_pressed()

func game_done():
	$CanvasLayer/Button.disabled = true

func _on_button_pressed() -> void:
	if input_handled_this_frame or not can_hit:
		return  # Already handled one input this frame
	check_hit()
	#if event is InputEventMouseButton:
		#if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			#check_hit()
			#input_handled_this_frame = true
			#
	#elif event is InputEventScreenTouch:
		#if event.pressed:
			#check_hit()
	input_handled_this_frame = true
