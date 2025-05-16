extends Node2D

#@onready var change_scene_area_to_world_2: InteractionArea = $change_scene_area_to_world_2
@onready var interaction_area: InteractionArea = $InteractionArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_toggle")

func _toggle():
	print("ehe")
	$".."._switch_to_world_2()
