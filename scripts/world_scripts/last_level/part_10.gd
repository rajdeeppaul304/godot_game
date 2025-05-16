extends Node2D


signal request_scene_change(world_name: String, spawn_point: String, is_speaking_scene: bool, dialogue_path: String, next_scene: String)

func next_scene():
	request_scene_change.emit("World3", "spawnpoint1", false)  # Or whatever scene you want
	
func previous_scene():
	request_scene_change.emit("last_level_part_7", "spawnpoint3", false)  # Or whatever scene you want



func _on_next_scene_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		next_scene()


func _on_previous_scene_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		previous_scene()
