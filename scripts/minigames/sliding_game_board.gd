extends Control

@export var size_tiles = 3
@export var tile_size = 80
@export var tile_scene: PackedScene
@export var slide_duration = 0.15
@onready var timer_label: Label = $CanvasLayer/CenterContainer/timer_label
@onready var timer: Timer = $CanvasLayer/CenterContainer/Timer

var board = []
var tiles = []
var empty = Vector2()
var is_animating = false
var tiles_animating = 0

var move_count = 0
var number_visible = true
var background_texture = null

enum GAME_STATES {
	NOT_STARTED,
	STARTED,
	WON
}
var game_state = GAME_STATES.NOT_STARTED
var game_lost_ = false

signal game_started
signal game_won
signal moves_updated
signal game_lost

func gen_board():
	var value = 1
	board = []
	for r in range(size_tiles):
		board.append([])
		for c in range(size_tiles):

			# choose which is empty cell
			if (value == size_tiles*size_tiles):
				board[r].append(0)
				empty = Vector2(c, r)
			else:
				board[r].append(value)

				# generate a new tile
				var tile = tile_scene.instantiate()
				tile.set_position(Vector2(c * tile_size, r * tile_size))
				tile.set_text(value)
				if background_texture:
					tile.set_sprite_texture(background_texture)
				tile.set_sprite(value-1, size_tiles, tile_size)
				tile.set_number_visible(number_visible)
				tile.connect("tile_pressed", Callable(self, "_on_Tile_pressed"))
				tile.connect("slide_completed", Callable(self, "_on_Tile_slide_completed"))
				add_child(tile)
				tiles.append(tile)

			value += 1

func is_board_solved():
	var count = 1
	for r in range(size_tiles):
		for c in range(size_tiles):
			if (board[r][c] != count):
				if r == c and c == size_tiles - 1 and board[r][c] == 0:
					return true
				else:
					return false
			count += 1
	return true

func print_board():
	print('------board------')
	for r in range(size_tiles):
		var row = ''
		for c in range(size_tiles):
			row += str(board[r][c]).pad_zeros(2) + ' '
		print(row)

func value_to_grid(value):
	for r in range(size_tiles):
		for c in range(size_tiles):
			if (board[r][c] == value):
				return Vector2(c, r)
	return null

func get_tile_by_value(value):
	for tile in tiles:
		if str(tile.number) == str(value):
			#print(tile)
			return tile
	return null

# testing
func _ready():
	tile_size = floor(get_size().x / size_tiles)
	print(tile_size)
	#tile_size = floor(get_size().x / size_tiles)
	#set_size(Vector2(tile_size*size_tiles, tile_size*size))
	var size_vec = Vector2(tile_size * size_tiles, tile_size * size_tiles)	
	set_size(size_vec)
	
	gen_board()
	print_board()

func _on_Tile_pressed(number: int) -> void:
	

	if is_animating:
		print("returning cause animation")
		return

	# Check if game is not started
	if game_state == GAME_STATES.NOT_STARTED:
		if game_lost_:
			return
		scramble_board()
		game_state = GAME_STATES.STARTED
		timer.start()
		emit_signal("game_started")
		
		return

	# Check if game is won
	if game_state == GAME_STATES.WON:
		#game_state = GAME_STATES.STARTED
		#reset_move_count()
		#scramble_board()
		#emit_signal("game_started")
		return

	var tile: Vector2i = value_to_grid(number)
	var empty: Vector2i = value_to_grid(0)

	# Only allow move in the same row or column as the empty tile
	if tile.x != empty.x and tile.y != empty.y:
		print("not empty direction")
		return
		
	print(board)
	
	var dir: Vector2i = Vector2i(sign(tile.x - empty.x), sign(tile.y - empty.y))
	var start: Vector2i = Vector2i(min(tile.x, empty.x), min(tile.y, empty.y))
	var end: Vector2i = Vector2i(max(tile.x, empty.x), max(tile.y, empty.y))

	# Slide each tile between start and end
	for r in range(end.y, start.y - 1, -1):
		for c in range(end.x, start.x - 1, -1):
			if board[r][c] == 0:
				continue
			var object := get_tile_by_value(board[r][c]) as TextureButton
			object.slide_to(Vector2((Vector2i(c, r) - dir)) * tile_size, slide_duration)
			is_animating = true
			tiles_animating += 1

	# Store current board state
	var old_board = []
	for row in board:
		old_board.append(row.duplicate())
	print(old_board, board)
	
	# Move tiles in row
	if tile.y == empty.y:
		print("before ", board[tile.y])
		if dir.x == -1:
			board[tile.y] = slide_row(board[tile.y], 1, start.x)
		else:
			board[tile.y] = slide_row(board[tile.y], -1, end.x)
		print("after ", board[tile.y])

	#print(old_board, board)
	
	# Move tiles in column
	if tile.x == empty.x:
		var col: Array = []
		for r in range(size_tiles):
			col.append(board[r][tile.x])

		if dir.y == -1:
			col = slide_column(col, 1, start.y)
		else:
			col = slide_column(col, -1, end.y)

		for r in range(size_tiles):
			board[r][tile.x] = col[r]
			
	print("after:",board)
	# Count how many moves were made
	var moves_made: int = 0
	for r in range(size_tiles):
		for c in range(size_tiles):
			#print(old_board[r]," ", board[r])
			#print(old_board[r][c]," ", board[r][c])
			if old_board[r][c] != board[r][c]:
				moves_made += 1

	move_count += moves_made - 1
	emit_signal("moves_updated", move_count)

	# Check win condition
	if is_board_solved():
		game_state = GAME_STATES.WON
		print("won")
		timer.stop()
		timer_label.text = "Congratulations you completed the puzzle!!"
		emit_signal("game_won")


func is_board_solvable(flat):
	var parity = 0
	var grid_width = size_tiles
	var row = 0
	var blank_row = 0
	for i in range(size_tiles*size_tiles):
		if i % grid_width == 0:
			row += 1

		if flat[i] == 0:
			blank_row = row
			continue

		for j in range(i+1, size_tiles*size_tiles):
			if flat[i] > flat[j] and flat[j] != 0:
				parity += 1

	if grid_width % 2 == 0:
		if blank_row % 2 == 0:
			return parity % 2 == 0
		else:
			return parity % 2 != 0
	else:
		return parity % 2 == 0

func scramble_board():
	reset_board()

	# generate a flat board with values 0 to size*size-1
	var temp_flat_board = []
	for i in range(size_tiles*size_tiles - 1, -1, -1):
		temp_flat_board.append(i)

	# keep shuffling until it is solvable
	randomize()
	temp_flat_board.shuffle()

	var is_solvable = is_board_solvable(temp_flat_board)
	while not is_solvable:
		randomize()
		temp_flat_board.shuffle()
		is_solvable = is_board_solvable(temp_flat_board)
	# convert flat 1d board to 2d board
	for r in range(size_tiles):
		for c in range(size_tiles):
			board[r][c] = temp_flat_board[r*size_tiles + c]
			if board[r][c] != 0:
				set_tile_position(r, c, board[r][c])
	empty = value_to_grid(0)


func reset_board():
	reset_move_count()
	board = []
	for r in range(size_tiles):
		board.append(([]))
		for c in range(size_tiles):
			board[r].append(r*size_tiles + c + 1)
			if r*size_tiles + c + 1 == size_tiles * size_tiles:
				board[r][c] = 0
			else:
				set_tile_position(r, c, board[r][c])
	empty = value_to_grid(0)

func set_tile_position(r: int, c: int, val: int):
	var object: TextureButton = get_tile_by_value(val)
	object.set_position(Vector2(c, r) * tile_size)

func _process(delta: float) -> void:
	
	if timer.time_left <= 0:
		timer_label.text = "Time's up!"
		return
	else:
		timer_label.text = str(floor(timer.time_left))
	pass
	#var current_time = int(floor(time_left))
	#if current_time != last_displayed_time:
		#last_displayed_time = current_time
		#time_label.text = str(current_time)
# used for using keyboard keys to play
#func _process(_delta):
	#var is_pressed = true
	#var dir = Vector2.ZERO
	#if (Input.is_action_just_pressed("left")):
		#dir.x = -1
	#elif (Input.is_action_just_pressed("right")):
		#dir.x = 1
	#elif (Input.is_action_just_pressed("up")):
		#dir.y = -1
	#elif (Input.is_action_just_pressed("down")):
		#dir.y = 1
	#else:
		#is_pressed = false
	#if is_pressed:
		#empty = value_to_grid(0)
#
		#var nr = empty.y + dir.y
		#var nc = empty.x + dir.x
		#if (nr == -1 or nc == -1 or nr >= size_tiles or nc >= size_tiles):
			#return
		#var tile_pressed = board[nr][nc]
		#print(tile_pressed)
		#_on_Tile_pressed(tile_pressed)

func slide_row(row: Array, dir: int, limiter: int) -> Array:
	var empty_index = row.find(0)

	if dir == 1:
		# slide towards the right
		var start = row.slice(0, limiter + 1)
		if start.size() > 0:
			start.pop_back()

		var pre = row.slice(limiter, empty_index + 1)
		if pre.size() > 0:
			pre.pop_back()

		var post = row.slice(empty_index, row.size())
		if post.size() > 0:
			post.pop_front()

		return start + [0] + pre + post
	else:
		# slide towards the left
		var pre = row.slice(0, empty_index + 1)
		if pre.size() > 0:
			pre.pop_back()

		var post = row.slice(empty_index, limiter + 1)
		if post.size() > 0:
			post.pop_front()

		var end = row.slice(limiter, row.size() - 1 + 1)
		if end.size() > 0:
			end.pop_front()

		return pre + post + [0] + end


func slide_column(col: Array, dir: int, limiter: int) -> Array:
	var empty_index = col.find(0)

	if dir == 1:
		# slide down
		var start = col.slice(0, limiter + 1)
		if start.size() > 0:
			start.pop_back()

		var pre = col.slice(limiter, empty_index + 1)
		if pre.size() > 0:
			pre.pop_back()

		var post = col.slice(empty_index, col.size() - 1 + 1)
		if post.size() > 0:
			post.pop_front()

		return start + [0] + pre + post
	else:
		# slide up
		var pre = col.slice(0, empty_index + 1)
		if pre.size() > 0:
			pre.pop_back()

		var post = col.slice(empty_index, limiter + 1)
		if post.size() > 0:
			post.pop_front()

		var end = col.slice(limiter, col.size() - 1 + 1)
		if end.size() > 0:
			end.pop_front()

		return pre + post + [0] + end

func _on_Tile_slide_completed(_number):
	tiles_animating -= 1
	if tiles_animating == 0:
		is_animating = false

func reset_move_count():
	move_count = 0
	emit_signal("moves_updated", move_count)

func set_tile_numbers(state):
	number_visible = state
	for tile in tiles:
		tile.set_number_visible(state)

func update_size(new_size):
	size_tiles = int(new_size)
	print('updating board size ', size_tiles)

	tile_size = floor(get_size().x / size_tiles)
	for tile in tiles:
		tile.queue_free()
	tiles = []
	gen_board()
	game_state = GAME_STATES.NOT_STARTED
	reset_move_count()

func update_background_texture(texture):
	background_texture = texture
	for tile in tiles:
		tile.set_sprite_texture(texture)
		tile.update_size(size_tiles, tile_size)


func _on_timer_timeout() -> void:
	if game_state in [GAME_STATES.WON, GAME_STATES.NOT_STARTED]:
		return
	else:
		game_state = GAME_STATES.NOT_STARTED
		game_lost_ = true
		game_lost.emit()
