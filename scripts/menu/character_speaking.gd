extends Node2D

# These will be set from the calling code
#var dialogue_file_location: String
signal request_scene_change(world_name: String, spawn_point: String, is_speaking_scene: bool, dialogue_path: String, next_scene: String)


var dialogue_file_location:= "res://dialogues/test_dialogue_1.dialogue"
var next_scene_file: String
var next_scene_spawn_point: String



func _ready() -> void:
	Manager.dialogue_has_ended.connect(_on_dialogue_finished)
	if dialogue_file_location != "":
		# Connect to a signal the DialogueManager will emit when done
		DialogueManager.dialogue_ended.connect(_on_dialogue_finished)
		
		start_dialogue()
		#DialogueManager.dia
	else:
		push_warning("No dialogue file set!")


func start_dialogue():
	DialogueManager.show_example_dialogue_balloon(load(dialogue_file_location), "start")

			#globalVariable.globalBoolean= false
#globalVariable is the name of autoload node script given. Refer the next code section i gave to see how to create this variable
#globalBoolean is the name of the variable inside the autoload script

#rest of the code that already exist

func _on_dialogue_finished():
	#print("Dialogue finished. Loading next scene...")
	request_scene_change.emit(next_scene_file, next_scene_spawn_point, false)  # Or whatever scene you want

	#get_tree().change_scene_to_file(next_scene_file)
