extends Node2D


var player
@onready var label: Label = $Label

const base_text : String = "[E] to "
#Manager.emit_connect_player.connect(connect_player)

var active_areas = []
var can_interact = true

func register_area(area :InteractionArea):
	active_areas.push_back(area)

func unregister_area(area :InteractionArea):
	var index = active_areas.find(area)
	if index != -1:
		active_areas.remove_at(index)

func _ready() -> void:
	Manager.emit_connect_player.connect(connect_player)


func _process(delta: float) -> void:
	if active_areas.size() > 0 and can_interact:
		
		active_areas.sort_custom(_sort_by_distance_to_player)
		label.text = base_text + active_areas[0].action_name
		label.global_position = active_areas[0].global_position
		label.global_position.y -= 36
		#label.global_position.x = label.size.x / 2
		#label.global_position.x = 10
		label.global_position.x =  active_areas[0].global_position.x - label.size.x / 2
		#print(label.size.x, label.global_position.x)
		#label.global_position.x =  active_areas[0].global_position.x - 550
		label.show()
	else:
		label.hide()



func _input(event):
	if event.is_action_pressed("attack") and can_interact:
		if active_areas.size() > 0:
			can_interact = false
			label.hide()
			await active_areas[0].interact.call()
			can_interact = true
		


func _sort_by_distance_to_player(area1, area2):
	var area1_to_player = player.global_position.distance_to(area1.global_position)
	var area2_to_player = player.global_position.distance_to(area2.global_position)
	return area1_to_player < area2_to_player


func connect_player(player_ref):
	#print("connected to intereation area")
	player = player_ref
