extends Node2D

@onready var player = $Player
var on_board:bool
@onready var platform_velocity := Vector2(0, 0) # Adjust as needed
@onready var area_2d_2: Area2D = $Area2D2
var in_falling_zone:bool
var player_is_alive_temp = true
# Movement settings
@onready var moving_boards: Node2D = $moving_boards
var board_states := {}
@onready var crystals: Node2D = $crystals


var start_x := 0.0
var move_range := 100.0  # Total horizontal range
var move_speed := 1.0    # How fast it moves


signal request_scene_change(world_name: String, spawn_point: String, is_speaking_scene: bool, dialogue_path: String, next_scene: String)

func next_scene():
	request_scene_change.emit("last_level_part_5", "spawnpoint1", false)

func previous_scene():
	request_scene_change.emit("last_level_part_3", "spawnpoint2", false) 

func set_spawn_point(spawn_point_name: String) -> void:
	var player = get_node("Player")
	var spawn_point = get_node("SpawnPoints/" + spawn_point_name)
	if player and spawn_point:
		player.global_position = spawn_point.global_position

func increase_z_index():
	var container = $z_index_increase_after_death
	
	# Get the player's position (assuming you have a player node)
	var player_pos = $Player.position  # Replace with your actual player node path

	for child in container.get_children():
		if child is Sprite2D:
			# Check if the player is above the child (compare the Y position)
			if player_pos.y < child.position.y:
				child.z_index = 10  # Player is above, set z-index to 10
			else:
				child.z_index = 0   # Player is below, set z-index to 0
	
	# increase the z index of enemies
	for child in get_children():
		print(child.name)
		if child.is_in_group("Enemy"):
			child.z_index = 15
	

func _ready() -> void:
	on_board = false
	#start_x = area_2d_2.position.x
	in_falling_zone = false
	for board in moving_boards.get_children():
		board.connect("left_platform", _left_platform)
		board.connect("onboarded_platform", _on_platform)
		board.connect("resume_player", _resume_player)
		
		#board_states[board.get_instance_id()] = false
	
	for crystal in crystals.get_children():
		crystal.connect("turned_on", _change_moving_boards)

func _resume_player():
	player.is_movement_paused = false


func _change_moving_boards(crystal_name):
	if crystal_name == "crystal1":
		$moving_boards/MovingBoard.change_points(Vector2(300, 456), Vector2(420, 456))
	elif crystal_name == "crystal2":
		$moving_boards/MovingBoard2.change_points(Vector2(180, 264), Vector2(60, 264))

	
func _left_platform(instance):
	board_states[instance] = false
	start_fall_effect(player)
	
func _on_platform(instance):
	board_states[instance] = true

func _process(delta: float) -> void:
	#print(board_states)
	#var offset = sin(Time.get_ticks_msec() / (1000.0 / move_speed)) * (move_range / 2)
	#var new_x = start_x + offset
	#var delta_x = new_x - area_2d_2.position.x
#
	#area_2d_2.position.x = new_x
	#platform_velocity = Vector2(delta_x, 0)

	if on_board and player:
		player.position += platform_velocity


func start_fall_effect(player_node: Node2D) -> void:
	var one_true = false
	for value in board_states.values():
		if value == true:
			one_true = true
	
	if one_true or not in_falling_zone:
		return
	increase_z_index()
	if not player_is_alive_temp:
		return
	
	player_is_alive_temp = false
	
	player_node.is_movement_paused = true
	player_node.anim.play("front_hit")
	player_node.apply_noise_shake()

	var tween = create_tween()
	var original_position = player_node.position
	var up_position = original_position - Vector2(0, 20)
	var down_position = original_position + Vector2(0, 50)

	#Step 1: Small hop upward
	tween.tween_property(player_node, "position", up_position, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Step 2: Fall downward while shrinking and fading
	tween.tween_property(player_node, "position", down_position, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(player_node, "scale", Vector2.ZERO, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(player_node, "modulate:a", 0.0, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	tween.tween_callback(Callable(self, "_on_fall_finished"))
	await tween.finished
	print("finished")
	#Manager.player_is_alive = false
	player.death_player("fell_off_crack")
	#get_parent().reset_level("fell_off_crack")
	# Disable input/movement processing if needed




func _on_fall_finished():
	print("Player has fallen!")
	# You can use `player.queue_free()` here or emit a signal to restart, etc.


#func _on_area_2d_2_body_entered(body: Node2D) -> void:
	#if body.name == "Player":
		#on_board = true
	#
#
#
#func _on_area_2d_2_body_exited(body: Node2D) -> void:
	#if body.name == "Player":
		#on_board = false
		#start_fall_effect(body)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and player_is_alive_temp:
		in_falling_zone = true
		start_fall_effect(body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		in_falling_zone = false
		start_fall_effect(body)



func _on_next_scene_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		next_scene()


func _on_previous_scene_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		previous_scene()
