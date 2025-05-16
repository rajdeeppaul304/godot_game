class_name EnemyStateMachine extends Node

@export var initial_state: EnemyState = null
@export var animation_player : AnimationPlayer = null
@export var sprite_2d : Sprite2D = null
@export var start_direction:Vector2 = Vector2(0, 1)

@onready var self_enemy = get_parent()

#@export var start_direction:String = "down"


@onready var state: EnemyState = (func get_initial_state() -> EnemyState:
	return initial_state if initial_state != null else get_child(0)
).call()


func _ready() -> void:
	#print("this ran")
	Manager.emit_connect_player.connect(connect_player)
	#connect_player(Manager.player)
	#if Manager.is_connected("emit_connect_player", Callable(self, "connect_player")):
		#print("Signal is connected.")
	#else:
		#print("Signal is NOT connected.")
		
	for state_node: EnemyState in find_children("*", "EnemyState"):
		state_node.finished.connect(_transition_to_next_state)
		state_node.animation_player = animation_player
		state_node.sprite_2d = sprite_2d
		state_node.self_enemy = self.get_parent()
	await owner.ready
	state.enter("", {"direction":start_direction})
	

func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)


func _process(delta: float) -> void:
	if Manager.player_is_alive:
		state.update(delta)


func _physics_process(delta: float) -> void:

	if Manager.player_is_alive :
		state.physics_update(delta)


func _transition_to_next_state(target_state_path: String, data: Dictionary = {}) -> void:
	if not self_enemy.is_dead:
		if not has_node(target_state_path):
			printerr(owner.name + ": Trying to transition to state " + target_state_path + " but it does not exist.")
			return

		var previous_state_path := state.name
		state.exit()
		state = get_node(target_state_path)
		state.enter(previous_state_path, data)


func connect_player(player_ref):
	print("enemy state connected")
	for state_node: EnemyState in find_children("*", "EnemyState"):
		state_node.player = player_ref
