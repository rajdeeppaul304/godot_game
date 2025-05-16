extends Node2D

@onready var t_rex_enemy: CharacterBody2D = $Enemy

signal request_scene_change(new_world_name: String, spawn_point: String)
var world_2_area_entered = false

func some_event_trigger():
	request_scene_change.emit("World2", "SpawnPoint2")  # Or whatever scene you want

func set_spawn_point(spawn_point_name: String) -> void:
	var player = get_node("Player")
	var spawn_point = get_node("SpawnPoints/" + spawn_point_name)
	if player and spawn_point:
		player.global_position = spawn_point.global_position

func _switch_to_world_2():
	if world_2_area_entered and not t_rex_enemy:
		some_event_trigger()



func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		world_2_area_entered = true

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		world_2_area_entered = false
