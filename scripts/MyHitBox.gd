class_name MyHitBox
extends Area2D

@export var damage : float= 10
var damage_name : String

func _init() -> void:
	collision_layer = 3
	collision_mask = 0

	

# call this from the parent node which has the hitbox
func set_current_damage_name(dam_name:String):
	damage_name = dam_name
	
func get_current_damage_name():
	return damage_name
	
func set_damage(dam):
	damage = dam

func get_damage():
	return damage
