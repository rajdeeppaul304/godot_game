## Virtual base class for all states.
## Extend this class and override its methods to implement a state.
class_name EnemyState extends Node

var self_enemy
var animation_player
var sprite_2d
var player
## Emitted when the state finishes and wants to transition to another state.
signal finished(next_state_path: String, data: Dictionary)

## Called by the state machine when receiving unhandled input events.
func handle_input(_event: InputEvent) -> void:
	pass

## Called by the state machine on the engine's main loop tick.
func update(_delta: float) -> void:
	pass

## Called by the state machine on the engine's physics update tick.
func physics_update(_delta: float) -> void:
	pass

## Called by the state machine upon changing the active state. The `data` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state_path: String, data := {}) -> void:
	pass

## Called by the state machine before changing the active state. Use this function
## to clean up the state.
func exit() -> void:
	pass
	

func play_directional_anim(angle: float, anim_name: String) -> void:
	if abs(angle) < PI / 4:
		animation_player.play("side_" + anim_name)
		sprite_2d.flip_h = true
	elif abs(angle) > 3 * PI / 4:
		animation_player.play("side_" + anim_name)
		sprite_2d.flip_h = false
	elif angle < 0:
		animation_player.play("back_" + anim_name)
	else:
		animation_player.play("front_" + anim_name)
