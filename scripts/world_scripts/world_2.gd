extends Node2D

signal request_scene_change(new_world_name: String, spawn_point: String)
var world_3_area_entered = false
@onready var player: Player = $Player
@onready var interaction_area: InteractionArea = $InteractionArea


func set_spawn_point(spawn_point_name: String) -> void:
	# Example logic, you can handle how to move the player based on the string
	var player = get_node("Player")
	var spawn_point = get_node("SpawnPoints/" + spawn_point_name)
	if player and spawn_point:
		player.global_position = spawn_point.global_position


func some_event_trigger():
	request_scene_change.emit("World3", "SpawnPoint1")  # Or whatever scene you want

func _switch_to_world_3():
	if world_3_area_entered:
		some_event_trigger()

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		world_3_area_entered = true

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		world_3_area_entered = false
