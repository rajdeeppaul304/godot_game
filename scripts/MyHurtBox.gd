class_name MyHurtBox
extends Area2D


func _init() -> void:
	collision_layer = 0
	collision_mask = 3


func _ready() -> void:
	connect("area_entered", self._on_area_entered)


func _on_area_entered(hitbox: MyHitBox) -> void:
	if hitbox == null:
		return
	
	# Check if the hitbox has a damage property or method
	if hitbox.has_method("get_damage") and hitbox.has_method("get_current_damage_name") and hitbox.has_method("get_knockback"):
		var damage = hitbox.get_damage()
		var damage_name = hitbox.get_current_damage_name()
		var knockback = hitbox.get_knockback()
	#var damage = 10

		if owner.has_method("take_damage"):
			# Call take_damage with the position of the hitbox and the damage amount
			owner.take_damage(damage, hitbox.position, damage_name, knockback)
