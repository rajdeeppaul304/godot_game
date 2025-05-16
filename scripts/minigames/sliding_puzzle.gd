extends TextureButton

var number: int

signal tile_pressed(number)
signal slide_completed(number)

# Update the number of the tile
func set_text(new_number: int) -> void:
	number = new_number
	$Number/Label.text = str(number)

# Update the background image of the tile
func set_sprite(new_frame: int, size: int, tile_size: int) -> void:
	var sprite = $Sprite2D
	
	update_size(size, tile_size)

	sprite.hframes = size
	sprite.vframes = size
	sprite.frame = new_frame

# Scale to the new tile_size
func update_size(size: int, tile_size: int) -> void:
	var new_size = Vector2(tile_size, tile_size)
	self.size = new_size
	$Number.size = new_size
	$Number/ColorRect.size = new_size
	$Number/Label.size = new_size
	#$Panel.size = new_size
	$Border.size = new_size
	var texture_size = $Sprite2D.texture.get_size()
	if texture_size != Vector2.ZERO:
		var to_scale = size * (new_size / texture_size)
		$Sprite2D.scale = to_scale

# Update the entire background image
func set_sprite_texture(texture: Texture2D) -> void:
	$Sprite2D.texture = texture

# Slide the tile to a new position
func slide_to(new_position: Vector2, duration: float) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(self, "position", new_position, duration) \
		.set_trans(Tween.TRANS_QUART) \
		.set_ease(Tween.EASE_OUT)
	await tween.finished
	emit_signal("slide_completed", number)

# Hide / Show the number of the tile
func set_number_visible(state: bool) -> void:
	$Number.visible = state

# Tile is pressed
#func _on_Tile_pressed() -> void:
	#emit_signal("tile_pressed", number)

# Tile has finished sliding
#func _on_Tween_tween_completed(object, key) -> void:
	#emit_signal("slide_completed", number)


func _on_pressed() -> void:
	print("number",number)
	emit_signal("tile_pressed", number)
