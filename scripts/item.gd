extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D

@export_enum("HealthPotion", "Projectile", "dragon_ball_1", "dragon_ball_2", "dragon_ball_3", "dragon_ball_4", "dragon_ball_5", "dragon_ball_6", "dragon_ball_7")
var item_name: String = "HealthPotion"

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

@export var move_distance: float = 50.0
@export var move_duration: float = 2
@export var collision_enable_delay: float = 2.5

var starting_movement = true
var final_position 
var float_amplitude :=3    # How far up/down it moves
var float_speed := 2        # How fast it moves
var base_y := 0.0              # Original Y position
var float_timer := 0.0         # Timer for sine wave

#signal item_picked(item_data)




func _ready() -> void:
	if item_name == "HealthPotion":	
		sprite_2d.texture = load("res://assets/UI_Elements/health_potion.png")
	elif item_name == "Projectile":	
		sprite_2d.texture = load("res://assets/UI_Elements/ranged_pickup.png")
	elif item_name.begins_with("dragon_ball_"):
		sprite_2d.texture = load("res://assets/characters/minigame_assets/dragon_balls/%s.png" % item_name)

			

	#base_y = position.y         # Store original Y position


var float_active := false  # Add this to track if float has started
func _physics_process(delta: float) -> void:
	var collision_info = move_and_collide(velocity * delta)

	if collision_info:
		print("velocity info:", velocity)
		velocity = velocity.bounce(collision_info.get_normal())

	# Simulate friction / slowing
	velocity -= velocity * delta * 4

	# Check if starting movement is done
	if starting_movement and velocity.length() < 1:
		print("this happened")
		starting_movement = false
		float_active = true
		base_y = sprite_2d.position.y  # Save original local Y of the sprite

func _process(delta: float) -> void:
	if float_active:
		await get_tree().create_timer(randf_range(0.8, 1.5)).timeout

		float_timer += delta * float_speed
		var float_offset = abs(sin(float_timer)) * float_amplitude
		sprite_2d.position.y = base_y - float_offset  # Always moves up smoothly

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		Manager.emit_item_picked_name(item_name)
		queue_free()
		#emit_signal("item_picked", self)
		#queue_free()  # Destroy item or play animation first
