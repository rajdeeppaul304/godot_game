extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_video_stream_player_finished() -> void:
	animation_player.play("fade_in")
	
	
func show_dialogue():
	$"CanvasLayer/Deco Location".visible = true
	#DialogueManager.show_example_dialogue_balloon(load("res://dialogues/test_dialogue_1.dialogue"), "start")

# screen size
var viewport_size = Vector2(1920, 1080)

@onready var parallax_layer: ParallaxLayer = $ParallaxBackground/ParallaxLayer
@onready var parallax_layer_2: ParallaxLayer = $ParallaxBackground/ParallaxLayer2
@onready var parallax_layer_3: ParallaxLayer = $ParallaxBackground/ParallaxLayer3
@onready var parallax_layer_4: ParallaxLayer = $ParallaxBackground/ParallaxLayer4
@onready var parallax_layer_5: ParallaxLayer = $ParallaxBackground/ParallaxLayer5


func _input(event):
	if event is InputEventMouseMotion:
		var mouse_x = event.position.x
		var mouse_y = event.position.y
		
		var relative_x = (mouse_x - (viewport_size.x/2)) / (viewport_size.x/2)
		var relative_y = (mouse_y - (viewport_size.y/2)) / (viewport_size.y/2)
		
		parallax_layer.motion_offset.x = 2 * relative_x
		parallax_layer.motion_offset.y = 2 * relative_y
		
		parallax_layer_2.motion_offset.x = 4 * relative_x
		parallax_layer_2.motion_offset.y = 4 * relative_y
		
		parallax_layer_3.motion_offset.x = 8 * relative_x
		parallax_layer_3.motion_offset.y = 8 * relative_y

		parallax_layer_4.motion_offset.x = 4 * relative_x
		parallax_layer_4.motion_offset.y = 4 * relative_y
		
		parallax_layer_5.motion_offset.x = 8 * relative_x
		parallax_layer_5.motion_offset.y = 8 * relative_y


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		animation_player.play("loop")
		show_dialogue()
