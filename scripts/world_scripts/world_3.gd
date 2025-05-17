extends Node2D

@onready var t_rex_enemy: CharacterBody2D = $Enemy
@onready var start_broly: Area2D = $start_broly

signal request_scene_change(world_name: String, spawn_point: String, is_speaking_scene: bool, dialogue_path: String, next_scene: String)

func next_scene():
	request_scene_change.emit("winner_screen", "spawnpoint1", true, "res://dialogues/test_dialogue_1.dialogue")  # Or whatever scene you want


func set_spawn_point(spawn_point_name: String) -> void:
	var player = get_node("Player")
	var spawn_point = get_node("SpawnPoints/" + spawn_point_name)
	if player and spawn_point:
		player.global_position = spawn_point.global_position

func _ready() -> void:
	$Enemy/EnemyStateMachine/coming_out.connect("coming_out_finished", _coming_out_finished)
	$Enemy/EnemyStateMachine/Death.connect("enemy_died", _enemy_died)
	$Player.can_shoot_projectile = false

func _enemy_died():
	next_scene()

func _coming_out_finished():
	$Player.is_movement_paused = false
	$Player.can_shoot_projectile = true

func _on_start_broly_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		$Player.is_movement_paused = true
		$Enemy.start_coming_out()
