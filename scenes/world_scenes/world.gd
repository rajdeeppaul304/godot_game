extends Node2D

signal request_scene_change(world_name: String, spawn_point: String, is_speaking_scene: bool, dialogue_path: String, next_scene: String)
var world_2_area_entered = false

func some_event_trigger():
	request_scene_change.emit("World2", "SpawnPoint1", true, "res://dialogues/test_dialogue_1.dialogue")  # Or whatever scene you want

func _switch_to_world_2():
	if world_2_area_entered:
		print("world_2_area_entered")
			#if body.has_method("player"):
		some_event_trigger()

#func _input(event: InputEvent) -> void:
	#if world_2_area_entered:
		#if event.is_action_pressed("attack") :
			##if body.has_method("player"):
			#some_event_trigger()


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		world_2_area_entered = true


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		world_2_area_entered = false
