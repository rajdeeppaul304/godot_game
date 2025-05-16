extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_on: bool = false  # Current torch state
var can_toggle: bool = true  # Toggle cooldown flag
var toggle_delay: float = 0.5  # Seconds

signal toggled

func _ready() -> void:
	is_on = false
	_update_animation()
	interaction_area.interact = Callable(self, "toggle")
	
# 🔁 Public toggle function with cooldown
func toggle() -> bool:
	if !can_toggle:
		return is_on

	can_toggle = false
	is_on = !is_on
	_update_animation()

	emit_signal("toggled")

	
	await get_tree().create_timer(toggle_delay).timeout
	can_toggle = true

	return is_on

# ✅ Explicit control functions if needed
func turn_on() -> void:
	if !is_on:
		is_on = true
		_update_animation()

func turn_off() -> void:
	if is_on:
		is_on = false
		_update_animation()

func is_on_state() -> bool:
	return is_on

# 🎬 Internal animation control
func _update_animation() -> void:
	if is_on:
		# Play flame_on once, then flame_loop
		animation_player.play("flame_on")
		await animation_player.animation_finished
		if is_on:  # Still on, in case state changed during animation
			animation_player.play("flame_loop")
	else:
		animation_player.play("flame_off")
