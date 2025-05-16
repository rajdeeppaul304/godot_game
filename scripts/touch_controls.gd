extends CanvasLayer


@export var player:CharacterBody2D # Adjust the path to your player node
#@onready var touch_control = $TouchControlButton      # Or a container node with multiple buttons
@onready var touch_control: TouchScreenButton = $left
@onready var dpad: Node2D = $dpad
@onready var actions: Node2D = $actions
@onready var touch_controls: CanvasLayer = $"."


func _process(delta):
	if not player and player.global_position:
		return

	#var camera = get_viewport().get_camera_2d()
	#var camera = player.get_node("Camera2D")
	#var player_position = player.global_position - camera.global_position
	
	var root = get_tree().root
	var player_position = (root.get_final_transform() * player.get_global_transform_with_canvas()).origin

	var action_position = actions.global_position  # Position of UI button (CanvasLayer)

	#var player_position = camera.get_screen_position(player.global_position)
	
	#var action_position = actions.global_position
	var dpad_position = dpad.global_position
	#var action_position = actions.global_position

	if player_position.x < dpad_position.x and player_position.y > dpad_position.y:
		for child in touch_controls.get_children():
			if child.is_in_group("dpad"):
				child.modulate.a = 0.2
	else:
		for child in touch_controls.get_children():
			if child.is_in_group("dpad"):
				child.modulate.a = 1
	
	if (player_position.x > action_position.x) and (player_position.y > action_position.y):
		for child in touch_controls.get_children():
			if child.is_in_group("action"):
				child.modulate.a = 0.2
	else:
		for child in touch_controls.get_children():
			if child.is_in_group("action"):
				child.modulate.a = 1
	

#(60.0, 613.0)(516.0, 554.0)
#(60.0, 613.0)(516.0, 554.0)
