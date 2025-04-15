extends Node

var player

var player_is_alive = true

var projectile_count:int = 100
var health_potion_count:int = 100
var max_player_health:float = 500
var player_health:float = max_player_health


signal item_picked_by_player(item_name)


func emit_item_picked_name(item_name):
	emit_signal("item_picked_by_player", item_name)


func reset_player():
	projectile_count = 100
	health_potion_count = 100
	player_health = max_player_health


func _on_player_registered(player_ref: CharacterBody2D) -> void:
	print("Player registered:", player_ref.name)
	player = player_ref

	# Now you can store the reference, call methods, etc.

# In Manager.gd
func register_player(player_node: CharacterBody2D) -> void:
	player_node.player_registered.connect(_on_player_registered)
	
