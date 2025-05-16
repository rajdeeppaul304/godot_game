extends Node2D
@onready var crystal: Node2D = $crystal

@onready var player: Player = $Player
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var total_enemies_spawned: int = 0
var enemies_died: int = 0


signal request_scene_change(world_name: String, spawn_point: String, is_speaking_scene: bool, dialogue_path: String, next_scene: String)

func next_scene():
	request_scene_change.emit("last_level_part_6", "spawnpoint1", false)

func previous_scene():
	request_scene_change.emit("last_level_part_4", "spawnpoint2", false) 

func set_spawn_point(spawn_point_name: String) -> void:
	var player = get_node("Player")
	var spawn_point = get_node("SpawnPoints/" + spawn_point_name)
	if player and spawn_point:
		player.global_position = spawn_point.global_position

func _ready() -> void:
	crystal.connect("turned_on", _close_doors)
	
func _close_doors(ref):
	player.is_movement_paused = true
	player.anim.play("front_idle")
	animation_player.play("door_close")


func _open_doors():
	animation_player.play("door_open")

	# spawn_enemies
	# how to know if the game started with enemies in the detection area

func spawn_enemies():
	total_enemies_spawned = 0
	enemies_died = 0

	for child in $enemies.get_children():
		if child.has_method("_spawn_enemy"):
			child.connect("spawned_enemy_died", _on_enemy_died)
			child._spawn_enemy(Manager.player)
			total_enemies_spawned += 1


func _on_enemy_died():
	enemies_died += 1
	if enemies_died >= total_enemies_spawned:
		_open_doors()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "door_close":
		player.is_movement_paused = false
		spawn_enemies()


func _on_next_scene_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		next_scene()


func _on_previous_scene_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		previous_scene()
