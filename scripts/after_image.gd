extends Sprite2D

@export var fade_time: float = 0.3
var timer := 0.0

func _ready():
	#modulate = Color(1, 0.4, 0.7, 0.6)
	scale *= 1.1 + randf() * 0.2  # slight random scaling
	rotation += randf() * 0.1 - 0.05

	var mat = CanvasItemMaterial.new()
	mat.blend_mode = 1  # 0 = MIX, 1 = ADD, 2 = SUB, 3 = MUL, etc.
	material = mat
	
func _process(delta: float) -> void:
	timer += delta
	var alpha = lerp(0.6, 0.0, timer / fade_time)
	modulate = modulate.lerp(Color(1, 0.2, 0.6, alpha), delta * 2)
	scale = scale.lerp(Vector2.ZERO, delta * (1.0 / fade_time))
	#position += Vector2(randf() - 0.5, randf() - 0.5) * 0.5
	modulate.a = alpha
	if timer >= fade_time:
		queue_free()
