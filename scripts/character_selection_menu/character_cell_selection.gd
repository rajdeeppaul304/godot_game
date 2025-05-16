extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("selected")

func _set_character_sprite_sheet(sheet_name:String):
	sprite_2d.texture = load(sheet_name)
	print("sheet loaded ", sheet_name)

func selected_on():
	#var mat := $Sprite2D.material as ShaderMaterial
	#mat.set_shader_parameter("grey_amount", 1.0)
	#mat.set_shader_parameter("blur_amount", 2.0)

	animation_player.play("selected")
	
func selected_off():
	animation_player.play("not_selected")

func nothing():
	animation_player.play("nothing")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
