extends Node2D

signal toggled_canvas(canvas_bool)

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var canvas_control: Control = $CanvasLayer/Panel
@onready var un_togglable:bool = false

func _ready():
	canvas_control.pivot_offset = canvas_control.size / 2
	interaction_area.interact = _toggle
	#canvas_layer.scale = HIDDEN_SCALE
	#canvas_layer.visible = false
	canvas_control.scale = HIDDEN_SCALE
	canvas_control.visible = false


var canvas_shown := false
var is_animating := false

const FULL_SCALE := Vector2(1, 1)
const HIDDEN_SCALE := Vector2(0, 0)
const TWEEN_DURATION := 0.4

#func _ready() -> void:

func make_untoggleable():
	un_togglable = true


func _toggle() -> void:
	if un_togglable:
		return
	if is_animating:
		return
	toggled_canvas.emit(canvas_shown)
	is_animating = true
	canvas_layer.visible = true
	canvas_control.visible = true
	
	var target_scale = FULL_SCALE if not canvas_shown else HIDDEN_SCALE

	var tween := create_tween()
	#tween.tween_property(canvas_layer, "scale", target_scale, TWEEN_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(canvas_control, "scale", target_scale, TWEEN_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	if canvas_shown:
		await tween.finished
		#canvas_layer.visible = false
		canvas_control.visible = false

	canvas_shown = not canvas_shown
	is_animating = false
