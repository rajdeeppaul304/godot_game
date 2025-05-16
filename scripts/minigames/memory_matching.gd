extends Control

signal game_won
signal game_lost

@onready var grid_container: GridContainer = $CenterContainer/GridContainer
@onready var card_scene: PackedScene = preload("res://scenes/minigames/card.tscn")
@onready var moves: Label = $moves
@onready var score: Label = $score

const NUM_CARDS = 16
const NUM_COLUMNS = 4
const TOTAL_PORTRAITS = 65
const MAX_MOVE_ALLOWED = 5

var max_score = NUM_CARDS/2
var cur_score = 0
var moves_done = 0
var cards := []
var flipped_cards := []  # Stores { position, index }
var solved_positions := []

var can_flip := true  # 🛑 flip lock

func _ready():
	var scale_grid = 3	
	#grid_container.scale = Vector2(scale_grid,scale_grid)
	grid_container.columns = NUM_COLUMNS
	#grid_container.set_pivot_offset(grid_container.rect_size / 2)
	#grid_container.anchor_left = 0.5
	#grid_container.anchor_top = 0.5
	#grid_container.anchor_right = 0.5
	#grid_container.anchor_bottom = 0.5
	print(grid_container.size)
	grid_container.pivot_offset = grid_container.size / 2

	# Scale the grid (will grow from center)
	grid_container.scale = Vector2(2.0, 2.0)  # 2x scale

	
	var available_indices := []
	for i in range(TOTAL_PORTRAITS):
		available_indices.append(i)
	available_indices.shuffle()

	var chosen_indices := available_indices.slice(0, NUM_CARDS / 2)

	var card_indices := []
	for i in chosen_indices:
		card_indices.append(i)
		card_indices.append(i)
	card_indices.shuffle()

	for i in range(NUM_CARDS):
		var card_instance = card_scene.instantiate()
		card_instance.set_front_texture(card_indices[i])
		card_instance.card_position = i
		card_instance.card_index = card_indices[i]
		card_instance.card_clicked.connect(_on_card_clicked)
		grid_container.add_child(card_instance)
		cards.append(card_instance)
		
	print(grid_container.size)

func _on_card_clicked(card_position: int, card_index: int):
	if moves_done == MAX_MOVE_ALLOWED:
		print("failed")
		game_lost.emit()
		return
		
	if !can_flip:
		return

	if card_position in solved_positions:
		return

	if flipped_cards.any(func(c): return c.position == card_position):
		return
	moves_done +=1
	moves.text =  "moves_left " + str(MAX_MOVE_ALLOWED - moves_done) 
	
	cards[card_position].flip_card()
	flipped_cards.append({ "position": card_position, "index": card_index })

	if flipped_cards.size() == 2:
		can_flip = false  # 🛑 Block flips while checking

		var card1 = flipped_cards[0]
		var card2 = flipped_cards[1]

		if card1.index == card2.index:
			# ✅ Match
			solved_positions.append(card1.position)
			solved_positions.append(card2.position)
			print("Match found: ", card1.index)
			cur_score += 1
			score.text = "score " + str(cur_score)
			if cur_score == max_score:
				score.text = "you won " 
				game_won.emit()
			await get_tree().create_timer(0.5).timeout  # 🕐 small delay before allowing next move
		else:
			# ❌ Not a match
			await get_tree().create_timer(1.0).timeout  # 🕐 show both cards for a second
			cards[card1.position].flip_card()
			cards[card1.position].shake_card()
			cards[card2.position].flip_card()
			cards[card2.position].shake_card()

		flipped_cards.clear()
		await get_tree().create_timer(1).timeout
		can_flip = true  # ✅ Allow next interaction
