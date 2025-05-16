extends Node2D


signal request_scene_change(world_name: String, spawn_point: String, is_speaking_scene: bool, dialogue_path: String, next_scene: String)

func next_scene():
	request_scene_change.emit("last_level_part_3", "spawnpoint1", false)

func previous_scene():
	request_scene_change.emit("last_level_part_1", "spawnpoint2", false) 

func previous_scene_2():
	request_scene_change.emit("last_level_part_9", "spawnpoint1", false) 


func set_spawn_point(spawn_point_name: String) -> void:
	var player = get_node("Player")
	var spawn_point = get_node("SpawnPoints/" + spawn_point_name)
	if player and spawn_point:
		player.global_position = spawn_point.global_position


func _on_next_scene_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		next_scene()


func _on_previous_scene_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		previous_scene()


func _on_previous_scene_2_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		previous_scene_2()
