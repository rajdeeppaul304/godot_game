extends CharacterBody2D

var pos: Vector2
var rota: float
var dir: float
var speed = 3

@onready var sprite: Sprite2D = $Sprite2D
@export var afterimage_scene: PackedScene
var afterimage_timer := 0.0
var afterimage_interval := 0.07
var min_afterimage_interval := 0.015  # Don't go faster than this
var interval_decrease_rate := 0.002   # How much faster each spawn is

func _ready() -> void:
	global_position = pos
	global_rotation = rota
	$MyHitBox.set_current_damage_name("projectile_1")

func _physics_process(delta: float) -> void:
	velocity = Vector2(speed, 0).rotated(dir)
	move_and_collide(velocity)

	# Spawn afterimage faster over time
	afterimage_timer += delta
	if afterimage_timer >= afterimage_interval:
		afterimage_timer = 0.0
		spawn_afterimage()
		# Decrease interval to spawn faster, but clamp to minimum
		afterimage_interval = max(min_afterimage_interval, afterimage_interval - interval_decrease_rate)

 
func spawn_afterimage():
	if afterimage_scene:
		var img = afterimage_scene.instantiate() as Sprite2D
		img.global_position = sprite.global_position
		img.global_rotation = sprite.global_rotation
		img.texture = sprite.texture
		img.scale = sprite.scale
		img.z_index = sprite.z_index - 1  # keep it behind
		get_tree().current_scene.add_child(img)

func _on_area_2d_area_entered(area: Area2D) -> void:
	queue_free()


#func _on_my_hit_box_area_entered(area: Area2D) -> void:
	#queue_free() # Replace with function body.
