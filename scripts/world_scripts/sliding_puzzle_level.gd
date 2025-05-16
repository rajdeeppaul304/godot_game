extends Node2D

signal request_scene_change(world_name: String, spawn_point: String, is_speaking_scene: bool, dialogue_path: String, next_scene: String)

var game_won = false
var game_lost = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Signpost.toggled_canvas.connect(_toggle_player_movement)
	#$Signpost/CanvasLayer/Panel/MemoryMatching.game_won.connect(_game_won)
	$Signpost/CanvasLayer/Panel/sliding_game_board.game_won.connect(_game_won)
	$Signpost/CanvasLayer/Panel/sliding_game_board.game_lost.connect(_game_lost)
	
func _toggle_player_movement(canvas_bool):
	# doing opposite of canvas bool as it await for the animation to update
	$Player.is_movement_paused = !canvas_bool

func next_scene():
	request_scene_change.emit("timing_bar_puzzle_5", "SpawnPoint1", true, "res://dialogues/test_dialogue_1.dialogue")  # Or whatever scene you want



#func _game_won():
	#await get_tree().create_timer(1.0).timeout
	#$Signpost._toggle()
	#await get_tree().create_timer(0.5).timeout
	#open_gate()
	#
#func _game_lost():
	#await get_tree().create_timer(1.0).timeout
	#$Signpost._toggle()
	#await get_tree().create_timer(0.5).timeout
	#open_gate()

func _game_won():
	if game_won == true:
		return
	game_won = true
	await get_tree().create_timer(1.0).timeout
	$Signpost._toggle()
	await get_tree().create_timer(0.5).timeout
	open_gate()
	
func _game_lost():
	if game_lost == true:
		return
	game_lost = true
	await get_tree().create_timer(1.0).timeout
	$Signpost._toggle()
	$Signpost.make_untoggleable()
	await get_tree().create_timer(0.5).timeout
	$Player.death_player("time_expired")


#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("attack"):
		#open_gate()

func open_gate():
	#var tween = create_tween()
	
	$Signpost/Sprite2D.texture = load("res://assets/characters/minigame_assets/memory_puzzle/off_signpost.png")
	$Player.is_movement_paused = true
	## Animate scale.x from 1 to 0 over 1 second
	#tween.tween_property($StaticBody2D2/Sprite2D, "scale:x", 0.0, 1.0)
	var tween = create_tween()
	var material := $Sprite2D2.material as ShaderMaterial
	tween.tween_property(material, "shader_parameter/wipe_progress", 1, 1.0) # 1 second
	await tween.finished
	
	$StaticBody2D2/CollisionShape2D.disabled = true
	
	$Player.is_movement_paused = false
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
