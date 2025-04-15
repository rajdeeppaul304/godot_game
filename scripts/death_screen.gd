extends Node2D

@onready var label: Label = $CanvasLayer/Label
@onready var tween: Tween = create_tween()

@onready var restart: Button = $CanvasLayer/GridContainer/restart
@onready var quit: Button = $CanvasLayer/GridContainer/quit

func _ready() -> void:
	label.scale = Vector2(1, 1)
	label.modulate.a = 0.0  # Start fully transparent

	restart.visible = false
	restart.modulate.a = 0.0  # Invisible initially

	quit.visible = false
	quit.modulate.a = 0.0  # Invisible initially


	


func start_death_screen():
	tween = create_tween()

	# Tween the label scale and fade in
	tween.tween_property(
		label, 
		"scale", 
		Vector2(5, 5), 
		5.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(
		label,
		"modulate:a",
		1.0,
		5.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await tween.finished

	# Show buttons and tween their alpha
	restart.visible = true
	quit.visible = true

	var button_tween = create_tween()
	button_tween.tween_property(restart, "modulate:a", 1.0, 1.0)
	button_tween.parallel().tween_property(quit, "modulate:a", 1.0, 1.0)


func _on_restart_pressed() -> void:
	Manager.player.player_sprite.queue_free()
	get_tree().change_scene_to_file("res://scenes/world.tscn")
	Manager.reset_player()
	Manager.player_is_alive = true


func _on_quit_pressed() -> void:
	get_tree().quit()
