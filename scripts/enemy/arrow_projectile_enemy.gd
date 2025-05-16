extends Node2D

const DIRECTIONS = {
	"right": Vector2.RIGHT,
	"left": Vector2.LEFT,
	"up": Vector2.UP,
	"down": Vector2.DOWN
}

@export var direction: String = "right" # Default direction
var velocity: Vector2 = Vector2.ZERO
var distance_traveled: float = 0.0
var max_distance: float = 2000.0
@export var speed: float = 200.0
var is_shooting: bool = false
@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	rotate_arrow()
	# Optional: auto-shoot on ready (for testing)
	# shoot()

func rotate_arrow() -> void:
	if DIRECTIONS.has(direction):
		rotation = DIRECTIONS[direction].angle()
	else:
		push_error("Invalid direction set on Arrow")

func shoot() -> void:
	print("arrow shot")
	if DIRECTIONS.has(direction):
		velocity = DIRECTIONS[direction] * speed
		is_shooting = true
	else:
		push_error("Invalid direction for Arrow")

func _process(delta: float) -> void:
	if not is_shooting:
		return

	var move_step = velocity * delta
	position += move_step
	distance_traveled += move_step.length()

	if distance_traveled >= max_distance:
		queue_free()

	## Perform collision check using PhysicsPointQueryParameters2D
	#var query = PhysicsPointQueryParameters2D.new()
	#query.position = global_position
	#query.collide_with_areas = true
	#query.collide_with_bodies = true
	#query.exclude = [self]
#
	#var space_state = get_world_2d().direct_space_state
	#var results = space_state.intersect_point(query)
#
	#for hit in results:
		#if hit.collider.is_in_group("player"):
			#queue_free()
			#break



func _on_area_2d_area_entered(area: Area2D) -> void:
	
	if area.get_parent().has_method("player"):
		if not is_shooting:
			return
		if Manager.player_is_alive:
			area.get_parent().take_player_damage(-10, position, 5, "death_by_arrow")
			is_shooting = false
		queue_free()
	else:
		$Area2D/CollisionShape2D.disabled = true
		is_shooting = false
		await get_tree().create_timer(4).timeout
		var tween = get_tree().create_tween()
		tween.tween_property($Sprite2D, "modulate:a", 0.0, 2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

		# Wait for the fade to finish (2 seconds)
		await get_tree().create_timer(2).timeout
		
		# After fade completes, free the object
		queue_free()
