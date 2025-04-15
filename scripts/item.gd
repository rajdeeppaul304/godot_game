extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

@export_enum("HealthPotion", "Projectile")
var item_name: String = "HealthPotion"

var float_amplitude := 2.5    # How far up/down it moves
var float_speed := 4        # How fast it moves
var base_y := 0.0              # Original Y position
var float_timer := 0.0         # Timer for sine wave

#signal item_picked(item_data)


func _ready() -> void:
	if item_name == "HealthPotion":	
		sprite_2d.texture = load("res://assets/UI_Elements/health_potion.png")
	elif item_name == "Projectile":	
		sprite_2d.texture = load("res://assets/UI_Elements/ranged_pickup.png")
		
		
	base_y = position.y         # Store original Y position

func _process(delta: float) -> void:
	float_timer += delta * float_speed
	position.y = base_y + sin(float_timer) * float_amplitude



func _on_area_entered(area: Area2D) -> void:
	Manager.emit_item_picked_name(item_name)
	queue_free()
	#emit_signal("item_picked", self)
	#queue_free()  # Destroy item or play animation first
