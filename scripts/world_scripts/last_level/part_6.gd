extends Node2D

@onready var crystal: Node2D = $crystal

var player_is_alive_temp = true
var in_falling_zone = false

signal request_scene_change(world_name: String, spawn_point: String, is_speaking_scene: bool, dialogue_path: String, next_scene: String)

func next_scene():
	request_scene_change.emit("last_level_part_7", "spawnpoint2", false)

func previous_scene():
	request_scene_change.emit("last_level_part_5", "spawnpoint2", false) 

func previous_scene2():
	request_scene_change.emit("last_level_part_8", "spawnpoint1", false) 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	crystal.connect("turned_on", _create_path)
	#_create_path()

func _create_path(ref):
	Manager.last_level_part_7_opened = true



func set_spawn_point(spawn_point_name: String) -> void:
	var player = get_node("Player")
	var spawn_point = get_node("SpawnPoints/" + spawn_point_name)
	if player and spawn_point:
		player.global_position = spawn_point.global_position

func start_fall_effect(player_node: Node2D) -> void:
	#var one_true = false
	#for value in board_states.values():
		#if value == true:
			#one_true = true
	
	if not in_falling_zone:
		return
		
	#increase_z_index()
	
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
	# Disable input/movement processing if needed
	#Manager.player_is_alive = false



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and player_is_alive_temp:
		in_falling_zone = true
		#start_fall_effect(body)

func _on_next_scene_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		next_scene()


func _on_previous_scene_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		previous_scene()


func _on_previous_scene_2_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		previous_scene2()
