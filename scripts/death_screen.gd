extends Node2D

@onready var label: Label = $CanvasLayer/Label
@onready var label2: Label = $CanvasLayer/CenterContainer/Label2

@onready var tween: Tween = create_tween()

@onready var restart: Button = $CanvasLayer/GridContainer/restart
@onready var quit: Button = $CanvasLayer/GridContainer/quit
var reason:String

func _ready() -> void:
	if Manager.reason_dict.has(reason):
		var lines = Manager.reason_dict[reason]
		var random_reason_line = lines[randi() % lines.size()]
		label2.text = random_reason_line
	else:
		label2.text = ""
	
	
	label2.visible = false
	label2.modulate.a = 0.0  # Invisible initially
	
	
	label.scale = Vector2(1, 1)
	label.modulate.a = 0.0  # Start fully transparent

	restart.visible = false
	restart.modulate.a = 0.0  # Invisible initially

	quit.visible = false
	quit.modulate.a = 0.0  # Invisible initially


	


func start_death_screen():
	tween = create_tween()

	# Animate label (scale to 5, fade in)
	tween.tween_property(label, "scale", Vector2(5, 5), 5.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(label, "modulate:a", 1.0, 5.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# label2 only fades in (no scale change)
	label2.modulate.a = 0.0
	tween.parallel().tween_property(label2, "modulate:a", 1.0, 5.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await tween.finished

	# Show and fade in buttons
	restart.visible = true
	quit.visible = true
	label2.visible = true
	
	var button_tween = create_tween()
	
	button_tween.tween_property(restart, "modulate:a", 1.0, 1.0)
	button_tween.parallel().tween_property(quit, "modulate:a", 1.0, 1.0)
	button_tween.parallel().tween_property(label2, "modulate:a", 1.0, 1.0)

	# Start flickering label2 continuously
	flicker_label2()


func flicker_label2() -> void:
	#label2.visible = true
	#label2.modulate.a = 1  # Invisible initially

	# Use a timer-based coroutine to loop flicker indefinitely
	await get_tree().create_timer(randf_range(0.3, 0.6)).timeout

	var flicker_tween = create_tween()
	var low_alpha = randf_range(0.3, 0.6)
	var fade_out_time = randf_range(0.1, 0.3)
	var fade_in_time = randf_range(0.1, 0.3)

	flicker_tween.tween_property(label2, "modulate:a", low_alpha, fade_out_time)
	flicker_tween.tween_property(label2, "modulate:a", 1.0, fade_in_time)

	await flicker_tween.finished

	# Call itself again to keep flickering
	flicker_label2()



func _on_restart_pressed() -> void:
	#Manager.player.player_sprite.queue_free()
	#get_tree().change_scene_to_file("res://scenes/world.tscn")
	Manager.emit_reset_level(reason)
	#Manager.player_is_alive = true


func _on_quit_pressed() -> void:
	get_tree().quit()
