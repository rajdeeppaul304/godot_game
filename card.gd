extends Control

signal card_clicked(card_position: int, card_index: int)



const back_texture = preload("res://assets/characters/portraits/back.png")
#@export var back_texture: Texture2D
@onready var sprite: Sprite2D = $Sprite2D
const ALL_PORTRAITS: Texture2D = preload("res://assets/characters/portraits/all_portraits.png")
var card_index: int
var card_position: int
var is_flipped = true
var flipping = false
var front_texture: AtlasTexture

const REGION_SIZE = Vector2i(64, 64)
var columns: int = ALL_PORTRAITS.get_width() / REGION_SIZE.x

@onready var area: Area2D = $Area2D




func _ready():
	if sprite.material :
		sprite.material = sprite.material.duplicate()
	#columns = 
	sprite.texture = back_texture
	#set_front_texture(5)
	#sprite.texture = front_texture
	#mouse_filter = Control.MOUSE_FILTER_PASS
	set_process_input(true)
	#flip_card()
	#area.input_event.connect(_on_area_input_event)

#func _on_area_input_event(viewport, event, shape_idx):
	#if event is InputEventMouseButton and event.pressed:
		#print("card cliked")
		#emit_signal("card_clicked", card_position, card_index)



func set_front_texture(index: int):
	card_index = index
	var col = index % columns
	var row = index / columns

	# If there's a horizontal gap of 5px between each portrait
	var region_x = col * (REGION_SIZE.x + 5)
	var region_y = row * REGION_SIZE.y
	var region_position = Vector2i(region_x, region_y)

	front_texture = AtlasTexture.new()
	front_texture.atlas = ALL_PORTRAITS
	front_texture.region = Rect2i(region_position, REGION_SIZE)

	
func flip_card():
	if flipping:
		return
	flipping = true

	var tween := create_tween()
	tween.tween_property(sprite.material, "shader_parameter/flip_progress", 1.0, 0.4).set_trans(Tween.TRANS_SINE)

	await get_tree().create_timer(0.2).timeout
	sprite.texture = back_texture if !is_flipped else front_texture
	is_flipped = !is_flipped

	await tween.finished
	sprite.material.set_shader_parameter("flip_progress", 0.0)
	#shake_card() # turn this on if you want to shake it even when flipping
	flipping = false



func shake_card():
	var original_pos = sprite.position
	var tween = create_tween()
	tween.tween_property(sprite, "position", original_pos + Vector2(5, -5), 0.05)
	tween.tween_property(sprite, "position", original_pos - Vector2(5, -5), 0.1)
	tween.tween_property(sprite, "position", original_pos - Vector2(5, 5), 0.05)
	tween.tween_property(sprite, "position", original_pos + Vector2(5, 5), 0.1)
	tween.tween_property(sprite, "position", original_pos, 0.1)  # Return to original


func _on_button_pressed() -> void:
	print("card cliked")
	emit_signal("card_clicked", card_position, card_index)
