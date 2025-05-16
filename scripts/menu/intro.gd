extends Node2D

signal request_scene_change(world_name: String, spawn_point: String, is_speaking_scene: bool, dialogue_path: String, next_scene: String)

@export_enum("Intro2", "Intro3", "speaking_piccolo") var next_world: String = "Intro2"


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		clicked_anywhere()   # Or whatever scene you want
	elif event is InputEventScreenTouch and event.pressed:
		clicked_anywhere()   # Or whatever scene you want
	elif event is InputEventKey and event.pressed:
		clicked_anywhere()  # Or whatever scene you want




func clicked_anywhere() -> void:
	if next_world ==  "speaking_piccolo":
		request_scene_change.emit("Character_selection", "SpawnPoint1", true, "res://dialogues/test_dialogue_1.dialogue")
		#request_scene_change.emit("Character_selection", "SpawnPoint1", false)  # Or whatever scene you want

		#request_scene_change.emit("World1", "SpawnPoint1", true, "res://dialogues/test_dialogue_1.dialogue")  # Or whatever scene you want
	else:
		request_scene_change.emit(next_world, "SpawnPoint1", false)  # Or whatever scene you want
