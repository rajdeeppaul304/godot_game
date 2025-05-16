extends Node2D

@export var start_pos: Vector2
@export var end_pos: Vector2
@export var move_speed: float = 1.0  # Speed of movement

signal left_platform(platform: Node)
signal onboarded_platform(platform: Node)
signal resume_player

var t := 0.0  # Normalized movement value (0 to 1)
var direction := 1.0
var platform_velocity := Vector2.ZERO
var on_board := false
var player: Node2D = null

@onready var area: Area2D = $Area2D

func _ready() -> void:
	position = start_pos

func _process(delta: float) -> void:
	
	
	t += direction * move_speed * delta

	# Reverse direction when reaching either end
	if t > 1.0:
		t = 1.0
		direction = -1.0
	elif t < 0.0:
		t = 0.0
		direction = 1.0

	var new_pos = start_pos.lerp(end_pos, t)
	platform_velocity = new_pos - position
	position = new_pos

	if on_board and player:
		player.position += platform_velocity

func _on_reached_new_start() -> void:
	t = 0.0  # Reset interpolation
	direction = 1.0
	set_process(true)  # Resume platform movement

func change_points(new_start: Vector2, new_end: Vector2) -> void:
	# Stop platform movement logic
	set_process(false)

	# Store new positions
	start_pos = new_start
	end_pos = new_end

	# Calculate movement duration
	var distance := position.distance_to(start_pos)
	var duration := distance / (move_speed * 100.0)

	# Create tween that updates position and moves player along
	var tween := create_tween()
	tween.tween_method(
		func(value):
			var delta_pos = value - position
			position = value
			if on_board and player:
				player.position += delta_pos
	, position, start_pos, duration)

	tween.tween_callback(Callable(self, "_on_reached_new_start"))

	


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		on_board = true
		player = body
		onboarded_platform.emit(self)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		on_board = false
		player = null
		left_platform.emit(self)
