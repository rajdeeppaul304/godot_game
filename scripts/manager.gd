extends Node


var current_player_info = {
		"name": "Goku",
		"sprite_location": "res://assets/characters/final_sprites/goku_sheet.png",
		"portrait_location": "res://assets/characters/character_selection/output/goku.png",
		"stats": { "Race": "Saiyan", "Power": 80, "Speed": 75, "Defense": 60 }
	}
var player
var last_level_part_7_opened = false


var reason_dict = {
	"timer_ran_out": [
		"Time’s up! The maze claimed another lost soul.",
		"You were so close... but the clock wasn't on your side.",
		"The exit was out there — but not in time.",
		"Wander too long, and the maze wins. Try again, faster this time!"
	],
	"death_by_enemy": [
		"Looks like the enemy got the best of you. Try again!",
		"The enemy's too strong this time. Better luck next round!",
		"You were taken down by the enemy. Time for a rematch!",
		"That enemy sure packed a punch! Let's see you fight back next time."
	],
	"moves_exhausted": [
		"You’ve run out of moves! You’ll have to be more strategic next time.",
		"No more moves left. Think ahead for your next attempt.",
		"Out of moves! Plan your next strategy more carefully.",
		"All moves used up! Time to try again with a fresh approach."
	],
	"failed_sequence_challenge": [
		"Oops, the sequence was too tricky. Try again!",
		"That sequence was a tough one! You’ll get it next time.",
		"You missed the sequence! Perfect timing next time!",
		"The sequence challenge caught you off guard. Focus and try again!"
	],
	"time_expired": [
		"Time’s up! You couldn’t finish in time.",
		"You ran out of time! Better hurry next time.",
		"The clock’s ticking! You didn’t make it in time.",
		"Looks like time wasn’t on your side this time."
	],
	"max_hits_reached": [
		"You didn’t break the rock in time! You’ve hit the max limit.",
		"You ran out of hits before breaking the rock.",
		"Max hits reached, but the rock is still intact. Try again!",
		"You didn’t break the rock within 10 hits. Better luck next time!"
	],
	"too_many_attempts": [
		"You’ve tried too many times. It’s time to reassess your strategy!",
		"Too many attempts and no success. Time to rethink your approach.",
		"You’ve exhausted all your tries. Let’s try again from the start.",
		"Too many attempts failed. You’ll need a better strategy."
	],
	"death_by_arrow": [
		"An arrow found its mark... unfortunately, it was you.",
		"You took an arrow to the everything. Ouch.",
		"Pierced by precision. Better dodge next time!",
		"Arrows don’t lie — and you were in the way."
	],
	"fell_off_crack": [
		"You fell off the edge! Be more careful next time.",
		"Watch your step! Falling off is not part of the plan.",
		"You slipped off the crack. Stay focused next time!",
		"A little misstep and you fell off. Get back on track!"
	]
};


enum BallState {
	NOT_COLLECTED,
	SKIPPED,
	COLLECTED
}

var ball_states: Dictionary = {
	"dragon_ball_1": BallState.NOT_COLLECTED,
	"dragon_ball_2": BallState.NOT_COLLECTED,
	"dragon_ball_3": BallState.NOT_COLLECTED,
	"dragon_ball_4": BallState.NOT_COLLECTED,
	"dragon_ball_5": BallState.NOT_COLLECTED,
	"dragon_ball_6": BallState.NOT_COLLECTED,
	"dragon_ball_7": BallState.NOT_COLLECTED
}

var player_is_alive = true

var projectile_count:int = 100
var health_potion_count:int = 100
var max_player_health:float = 20
var player_health:float = max_player_health

signal reset_level(reason)
signal item_picked_by_player(item_name)
signal emit_connect_player(player_ref)
signal dialogue_has_ended

#Manager.emit_connect_player.connect(connect_player)

#func emit_connect_player(player_ref):
	#emit_signal("item_picked_by_player", player_ref)

#func _ready() -> void:
	#dialogue_has_ended.connect(_on_my_signal)

#func _on_my_signal():
	#print("hha")

func skip_ball(item_name):
	if item_name.begins_with("dragon_ball_"):
		ball_states[item_name] = BallState.SKIPPED


func emit_item_picked_name(item_name):
	if item_name.begins_with("dragon_ball_"):
		ball_states[item_name] = BallState.COLLECTED


	emit_signal("item_picked_by_player", item_name)


func emit_reset_level(reason):
	print(reason, "reason")
	reset_level.emit(reason)


func reset_player():
	#projectile_count = 100
	#health_potion_count = 100
	player_health = max_player_health


func _on_player_registered(player_ref: CharacterBody2D) -> void:
	print("Player registered:", player_ref.name)
	#print(player_ref)
	player = player_ref
	emit_signal("emit_connect_player", player)




func register_player(player_node: CharacterBody2D) -> void:
	player_node.player_registered.connect(_on_player_registered)
	
