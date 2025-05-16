extends Control

var character_data_json = {
	0: {
		"name": "Goku",
		"sprite_location": "res://assets/characters/final_sprites/goku_sheet.png",
		"portrait_location": "res://assets/characters/character_selection/output/goku.png",
		"stats": { "Race": "Saiyan", "Power": 80, "Speed": 75, "Defense": 60 }
	},
	1: {
		"name": "Android 18",
		"sprite_location": "res://assets/characters/final_sprites/android_18-sheet.png",
		"portrait_location": "res://assets/characters/character_selection/output/android_18.png",
		"stats": { "Race": "Android", "Power": 75, "Speed": 80, "Defense": 60 }
	},
	2: {
		"name": "Android 17",
		"sprite_location": "res://assets/characters/final_sprites/android_17-sheet.png",
		"portrait_location": "res://assets/characters/character_selection/output/android_17.png",
		"stats": { "Race": "Android", "Power": 70, "Speed": 85, "Defense": 60 }
	},
	3: {
		"name": "Dr Gero",
		"sprite_location": "res://assets/characters/final_sprites/dr_gero-sheet.png",
		"portrait_location": "res://assets/characters/character_selection/output/android_17.png",
		"stats": { "Race": "Human/Cyborg", "Power": 65, "Speed": 70, "Defense": 80 }
	},
	4: {
		"name": "Future Trunks",
		"sprite_location": "res://assets/characters/final_sprites/future_trunks-sheet.png",
		"portrait_location": "res://assets/characters/character_selection/output/future_trunks.png",
		"stats": { "Race": "Half-Saiyan", "Power": 85, "Speed": 70, "Defense": 60 }
	},
	5: {
		"name": "Gohan Adult",
		"sprite_location": "res://assets/characters/final_sprites/gohan_adult-sheet.png",
		"portrait_location": "res://assets/characters/character_selection/output/gohan_adult.png",
		"stats": { "Race": "Half-Saiyan", "Power": 75, "Speed": 65, "Defense": 75 }
	},
	6: {
		"name": "Gohan Kid",
		"sprite_location": "res://assets/characters/final_sprites/gohan_kid-sheet.png",
		"portrait_location": "res://assets/characters/character_selection/output/gohan_adult.png",
		"stats": { "Race": "Half-Saiyan", "Power": 70, "Speed": 75, "Defense": 70 }
	},
	7: {
		"name": "Gotenks",
		"sprite_location": "res://assets/characters/final_sprites/gotenks-sheet.png",
		"portrait_location": "res://assets/characters/character_selection/output/gotenks.png",
		"stats": { "Race": "Fusion (Saiyan)", "Power": 90, "Speed": 70, "Defense": 55 }
	},
	8: {
		"name": "Hercule",
		"sprite_location": "res://assets/characters/final_sprites/hercule-sheet.png",
		"portrait_location": "res://assets/characters/character_selection/output/hercule.png",
		"stats": { "Race": "Human", "Power": 50, "Speed": 65, "Defense": 100 }
	},
	9: {
		"name": "Kid Buu",
		"sprite_location": "res://assets/characters/final_sprites/kid_buu-sheet.png",
		"portrait_location": "res://assets/characters/character_selection/output/kid_buu.png",
		"stats": { "Race": "Majin", "Power": 85, "Speed": 85, "Defense": 45 }
	},
	10: {
		"name": "Piccolo",
		"sprite_location": "res://assets/characters/final_sprites/piccolo-sheet_1.png",
		"portrait_location": "res://assets/characters/character_selection/output/piccolo.png",
		"stats": { "Race": "Namekian", "Power": 70, "Speed": 60, "Defense": 85 }
	},
	11: {
		"name": "Trunks",
		"sprite_location": "res://assets/characters/final_sprites/trunks-sheet.png",
		"portrait_location": "res://assets/characters/character_selection/output/trunks_kid.png",
		"stats": { "Race": "Half-Saiyan", "Power": 75, "Speed": 78, "Defense": 62 }
	},
	12: {
		"name": "Vegeta",
		"sprite_location": "res://assets/characters/final_sprites/vegeta-sheet.png",
		"portrait_location": "res://assets/characters/character_selection/output/vegeta.png",
		"stats": { "Race": "Saiyan", "Power": 88, "Speed": 70, "Defense": 57 }
	},
	13: {
		"name": "Videl",
		"sprite_location": "res://assets/characters/final_sprites/videl-sheet.png",
		"portrait_location": "res://assets/characters/character_selection/output/videl.png",
		"stats": { "Race": "Human", "Power": 65, "Speed": 80, "Defense": 70 }
	}
};

signal request_scene_change(world_name: String, spawn_point: String, is_speaking_scene: bool, dialogue_path: String, next_scene: String)


@onready var left_button: Button = $CanvasLayer/Panel/Panel/left
@onready var right_button: Button = $CanvasLayer/Panel/Panel/right
@onready var portrait: TextureRect = $CanvasLayer/Panel2/GridContainer/Panel/portrait


#@onready var grid_container: GridContainer = $Panel/GridContainer
@onready var grid_container: GridContainer = $CanvasLayer/Panel/GridContainer
var visible_slots := 5
var selected_index := 0  # The center index in the full list
var total_characters := character_data_json.size()
var display_indices := [-1, -1, 0, 1, 2]
#var total_characters := 6  # Or however many characters you have

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#var c = 0
	#for i in grid_container.get_children():
		#if c<2:
			#i.get_child(0).nothing()
		#elif c==2:
			#i.get_child(0)._set_character_sprite_sheet(character_data_json[0]["sprite_location"])
#
			#i.get_child(0).selected_on()
		#else:
			#i.get_child(0)._set_character_sprite_sheet(character_data_json[1]["sprite_location"])
#
			#i.get_child(0).selected_off()
		#c+=1

func _ready() -> void:
	display_sprites()  # Custom trigger to load initial state
	shift_display_indices("left")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func shift_display_indices(direction: String) -> void:
	if direction == "left" and display_indices[0] == -1 and display_indices[1] == -1:
		left_button.disabled = true
		return
	
	if direction == "right" and display_indices[3] == -1 and display_indices[4] == -1:
		return
	
	left_button.disabled = false
	
	var new_center = display_indices[2]

	if direction == "left":
		new_center -= 1
	elif direction == "right":
		new_center += 1
	else:
		return

	var new_array := []
	for i in range(new_center - 2, new_center + 3):
		if i >= 0 and i < total_characters:
			new_array.append(i)
		else:
			new_array.append(-1)

	display_indices = new_array
	display_sprites()

func display_sprites() -> void:
	for i in range(5):
		var slot = grid_container.get_child(i)
		var character_index = display_indices[i]
		if character_index >=0:
			var sprite_path = character_data_json[character_index]["sprite_location"]
			slot.get_child(0)._set_character_sprite_sheet(sprite_path)

			if i == 2:
				slot.get_child(0).selected_on()
				change_currently_selected()
			else:
				print("selected_off", character_index)
				slot.get_child(0).selected_off()
		else:
			slot.get_child(0).nothing()

func _on_left_pressed() -> void:
	shift_display_indices("left")
	print(display_indices)

@onready var name_label: Label = $CanvasLayer/Panel2/GridContainer/Panel2/VBoxContainer/name
@onready var race_label: Label = $CanvasLayer/Panel2/GridContainer/Panel2/VBoxContainer/race
@onready var power_bar: ProgressBar = $CanvasLayer/Panel2/GridContainer/Panel2/VBoxContainer/StatContainer/PowerRow/PowerBarContainer/CenterContainer/PowerBar
const SCRAMBLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890!@#$%^&*"

func scramble_text(label: Label, prefix: String, target_text: String, speed: float = 0.05):
	var resolved = ""
	var tween = create_tween()
	var total_length = target_text.length()
	var current_speed = speed
	
	for i in range(total_length):
		# Animate each letter position over time
		var step_timer := Timer.new()
		step_timer.wait_time = current_speed
		step_timer.one_shot = true
		add_child(step_timer)
		step_timer.start()
		
		await step_timer.timeout
		
		# Flicker a few random characters before locking in the correct one
		for j in range(5):  # number of flickers per letter
			var rand_text = resolved + SCRAMBLE_CHARACTERS[randi() % SCRAMBLE_CHARACTERS.length()]
			label.text = "%s%s" % [prefix, rand_text]
			await get_tree().create_timer(current_speed / 2).timeout
		
		# Lock in the correct letter
		resolved += target_text[i]
		label.text = "%s%s" % [prefix, resolved]
		
		# Speed up the effect as we progress
		current_speed = max(0.01, current_speed * 0.85)  # Speed up as the letters settle

	# Final correct string
	label.text = "%s%s" % [prefix, target_text]




func update_stats(stats: Dictionary):
	print(stats)

	# Reset labels for transition
	name_label.modulate.a = 0.0
	#race_label.modulate.a = 0.0
	name_label.position.x = -300
	#race_label.position.x = -300

	# Animate name label in
	var tween = create_tween()
	name_label.text = "Name: %s" % stats["name"]
	tween.tween_property(name_label, "position:x", 0, 0.5) \
		 .set_trans(Tween.TRANS_BACK) \
		 .set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(name_label, "modulate:a", 1.0, 0.5)

	# Animate race label in (delayed slightly)
	race_label.text = "Race: %s" % stats["stats"]["Race"]
	#tween.tween_interval(0.1)
	#tween.tween_property(race_label, "position:x", 0, 0.5) \
		 #.set_trans(Tween.TRANS_BACK) \
		 #.set_ease(Tween.EASE_OUT)
	#tween.parallel().tween_property(race_label, "modulate:a", 1.0, 0.5)
	scramble_text(race_label, "Race: ", stats["stats"]["Race"])

	#tween.parallel().tween_property(name_label, "modulate", Color(1, 1, 0.8), 0.5) \
	 #.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	#tween.parallel().tween_property(name_label, "modulate", Color(1, 1, 1), 0.3)

	# Animate bars
	tween.tween_interval(0.2)
	animate_bar(power_bar, stats["stats"]["Power"])
	tween.tween_interval(0.1)
	#animate_bar(speed_bar, stats["stats"]["Speed"])
	tween.tween_interval(0.1)
	#animate_bar(defense_bar, stats["stats"]["Defense"])


func animate_bar(bar: ProgressBar, target_value: float):
	bar.value = 0
	var tween = create_tween()
	tween.tween_property(bar, "value", target_value, 1.0) \
		 .set_trans(Tween.TRANS_SINE) \
		 .set_ease(Tween.EASE_OUT)



func change_currently_selected():
	var portrait_location = character_data_json[display_indices[2]]["portrait_location"]
	portrait.texture = load(portrait_location)
	update_stats(character_data_json[display_indices[2]])
func _on_right_pressed() -> void:
	shift_display_indices("right")
	print(display_indices)
	


func _on_button_pressed() -> void:
	Manager.current_player_info = character_data_json[display_indices[2]]
	
	request_scene_change.emit("maze_puzzle_1", "SpawnPoint1", true, "res://dialogues/test_dialogue_1.dialogue")
	
	#request_scene_change.emit("maze_puzzle_1", "SpawnPoint1", false)  # Or whatever scene you want
