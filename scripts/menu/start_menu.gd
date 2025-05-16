extends Node2D

signal request_scene_change(world_name: String, spawn_point: String, is_speaking_scene: bool, dialogue_path: String, next_scene: String)




func _on_button_pressed() -> void:
	request_scene_change.emit("Intro1", "SpawnPoint1", false)  # Or whatever scene you want
