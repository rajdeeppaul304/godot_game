extends Control

var scenes := {
	"Start_menu": preload("res://scenes/menu/start_menu.tscn"),
	"Intro1": preload("res://scenes/menu/intro.tscn"),
	"Intro2": preload("res://scenes/menu/intro2.tscn"),
	"Intro3": preload("res://scenes/menu/intro3.tscn"),
	"Character_selection": preload("res://scenes/character_selection_menu/character_select.tscn"),
	"maze_puzzle_1": preload("res://scenes/minigames/maze.tscn"),
	"memory_matching_puzzle_2": preload("res://scenes/world_scenes/memroy_matching_level.tscn"),
	"shooter_game_puzzle_3": preload("res://scenes/minigames/shooter_game.tscn"),
	"sliding_puzzle_4": preload("res://scenes/world_scenes/sliding_puzzle_level.tscn"),
	"timing_bar_puzzle_5": preload("res://scenes/world_scenes/timing_bar_level.tscn"),
	"trial_of_lights_6": preload("res://scenes/minigames/trial_of_flames.tscn"),

	"last_level_part_1": preload( "res://scenes/world_scenes/last_level/part_1.tscn"),
	"last_level_part_2": preload("res://scenes/world_scenes/last_level/part_2.tscn" ),
	"last_level_part_3": preload("res://scenes/world_scenes/last_level/part_3.tscn" ),
	"last_level_part_4": preload( "res://scenes/world_scenes/last_level/part_4.tscn"),
	"last_level_part_5": preload( "res://scenes/world_scenes/last_level/part_5.tscn"),
	"last_level_part_6": preload("res://scenes/world_scenes/last_level/part_6.tscn" ),
	"last_level_part_7": preload( "res://scenes/world_scenes/last_level/part_7.tscn"),
	"last_level_part_8": preload( "res://scenes/world_scenes/last_level/part_8.tscn"),
	"last_level_part_9": preload( "res://scenes/world_scenes/last_level/part_9.tscn"),
	"last_level_part_10": preload("res://scenes/world_scenes/last_level/part_10.tscn"),
	"last_level_part_11": preload("res://scenes/world3.tscn"),
	"winner_screen": preload("res://scenes/world_scenes/winner_screen.tscn"),




	"World1": preload("res://scenes/world.tscn"),
	"World2": preload("res://scenes/World2.tscn"),
}






var current_world: Node = null
var current_world_name:String = ""
#@onready var fade_rect: ColorRect = $CanvasLayer/ColorRect
@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var canvas_layer: CanvasLayer = $CanvasLayer

func _ready():
	Manager.connect("reset_level", _reset_level)
	#load_world("Start_menu", "DefaultSpawn")
	load_world("maze_puzzle_1", "spawnpoint1")



func load_world(world_name: String, spawn_point: String, is_speaking_scene := false, dialogue_path := "") -> void:
	await fade_and_switch(world_name, spawn_point, is_speaking_scene, dialogue_path)


func _on_scene_change_requested(world_name: String, spawn_point: String, is_speaking_scene := false, dialogue_path := "") -> void:
	load_world(world_name, spawn_point, is_speaking_scene , dialogue_path)

func fade_and_switch(world_name: String, spawn_point: String, is_speaking_scene: bool, dialogue_path: String) -> void:
	animator.play("fade_to_black")
	canvas_layer.layer = 2
	await animator.animation_finished
	# may result in bugs. as we are setting the player alive from here in the animation logic
	Manager.player_is_alive = true
	
	if current_world:
		current_world.queue_free()
		
	
	if is_speaking_scene:
		var dialogue_scene = load("res://scenes/menu/character_speaking.tscn").instantiate()
		dialogue_scene.dialogue_file_location = dialogue_path
		dialogue_scene.next_scene_file = world_name
		add_child(dialogue_scene)
		current_world = dialogue_scene
		current_world_name = world_name
		if dialogue_scene.has_signal("request_scene_change"):
			dialogue_scene.request_scene_change.connect(_on_scene_change_requested)
			
		dialogue_scene.next_scene_spawn_point = spawn_point
		
		animator.play("fade_from_black")
		await animator.animation_finished
		
		return  

	if scenes.has(world_name):
		var scene = scenes[world_name].instantiate()
		add_child(scene)
		current_world = scene
		current_world_name = world_name
		# Pass spawn point to the new world
		if current_world.has_method("set_spawn_point"):
			current_world.set_spawn_point(spawn_point)

		# Connect scene change signal
		if scene.has_signal("request_scene_change"):
			scene.request_scene_change.connect(_on_scene_change_requested)
		Manager.reset_player()
	else:
		push_error("Scene not found: " + world_name)

	animator.play("fade_from_black")
	await animator.animation_finished
	canvas_layer.layer = 1



# level you are on: { reason : [level to go on, spawnpoint]}
var reset_level_dict = {
	"maze_puzzle_1": {
		"death_by_enemy": ["maze_puzzle_1", "spawnpoint1"],
		"timer_ran_out": ["maze_puzzle_1", "spawnpoint1"]

	},
	"memory_matching_puzzle_2": {
		"death_by_enemy": ["memory_matching_puzzle_2", "spawnpoint1"],
		"moves_exhausted": ["memory_matching_puzzle_2", "spawnpoint1"]
	},
	"shooter_game_puzzle_3": {
		"death_by_enemy": ["shooter_game_puzzle_3", "spawnpoint1"],
		"failed_sequence_challenge": ["shooter_game_puzzle_3", "spawnpoint1"]
	},
	"sliding_puzzle_4": {
		"death_by_enemy": ["sliding_puzzle_4", "spawnpoint1"],
		"time_expired": ["sliding_puzzle_4", "spawnpoint1"]
	},
	"timing_bar_puzzle_5": {
		"death_by_enemy": ["timing_bar_puzzle_5", "spawnpoint1"],
		"max_hits_reached": ["timing_bar_puzzle_5", "spawnpoint1"]
	},
	"trial_of_lights_6": {
		"too_many_attempts": ["trial_of_lights_6", "spawnpoint1"],
		"death_by_enemy": ["last_level_part_1", "spawnpoint1"]
	},
	"last_level_part_1": {
		"death_by_enemy": ["last_level_part_1", "spawnpoint1"]
	},
	"last_level_part_2": {
		"death_by_enemy": ["last_level_part_1", "spawnpoint1"]
	},
	"last_level_part_3": {
		"death_by_enemy": ["last_level_part_1", "spawnpoint1"],
		"death_by_arrow": ["last_level_part_1", "spawnpoint1"]
	},
	"last_level_part_4": {
		"fell_off_crack": ["last_level_part_1", "spawnpoint1"],
		"death_by_enemy": ["last_level_part_1", "spawnpoint1"]
	},
	"last_level_part_5": {
		"death_by_enemy": ["last_level_part_1", "spawnpoint1"]
	},
	"last_level_part_6": {
		#"fell_off_crack": ["last_level_part_1", "spawnpoint1"],
		"death_by_enemy": ["last_level_part_1", "spawnpoint1"]
	},
	"last_level_part_7": {
		"death_by_enemy": ["last_level_part_1", "spawnpoint1"]
	},
	"last_level_part_8": {
		"death_by_enemy": ["last_level_part_1", "spawnpoint1"]
	},
	"last_level_part_9": {
		"death_by_enemy": ["last_level_part_1", "spawnpoint1"]
	},
	"last_level_part_10": {
		"death_by_enemy": ["last_level_part_1", "spawnpoint1"]
	}
}


# use this if you die in a level shall take the level that you are in , 
# and a soft parameter based on which it decides where it should reset level to
# does not work for speaking scenes, as they wont be replayed
# may implement in the future
func reset_level(reason):
	if not reset_level_dict.has(current_world_name):
		load_world(current_world_name, "spawnpoint1")
		push_error("reset level dict doesnt have: " + current_world_name)
		return
	
	var world_data = reset_level_dict[current_world_name]
	
	if not world_data.has(reason):
		load_world(current_world_name, "spawnpoint1")
		push_error("reset level dict doesnt have reason: " + current_world_name + reason)
		return
		
	print(reason, " reason")
	var reason_data = world_data[reason]

	if typeof(reason_data) != TYPE_ARRAY or reason_data.size() < 2:
		push_error("reset level dict doesnt have reason , new_world name or spawnpoint name: " + current_world_name + reason)
		load_world(current_world_name, "spawnpoint1")
		return

	var new_world_name = reason_data[0]
	var spawn_point = reason_data[1]

	load_world(new_world_name, spawn_point)


	
		
		
func _reset_level(reason):
	reset_level(reason)
	pass
