extends Node2D

signal request_scene_change(world_name: String, spawn_point: String, is_speaking_scene: bool, dialogue_path: String, next_scene: String)
#var world_2_area_entered = false
@onready var timer: Timer = $Timer

func next_scene():
	request_scene_change.emit("memory_matching_puzzle_2", "SpawnPoint1", true, "res://dialogues/test_dialogue_1.dialogue")  # Or whatever scene you want
	#request_scene_change.emit("last_level_part_10", "spawnpoint1", true, "res://dialogues/test_dialogue_1.dialogue")  # Or whatever scene you want


func _ready() -> void:
	timer.start()

func _game_lost():
	$Player.is_movement_paused = true
	await get_tree().create_timer(2).timeout
	$Player.death_player("timer_ran_out")
	

func _on_timer_timeout() -> void:
	_game_lost()
