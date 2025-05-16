extends Marker2D

var enemy_scene_file = load("res://scenes/enemy.tscn")

signal spawned_enemy_died

@export var detection_collision_radius: float = 55
@export var death_particles_Modulate : Color = Color(100,100,0.8,1)
@export var enemy_sprite: Texture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _spawn_enemy(player_ref):
	var enemy_scene = enemy_scene_file.instantiate()
	enemy_scene.position = global_position
	get_parent().get_parent().add_child(enemy_scene)
	enemy_scene.get_node("EnemyStateMachine/Death").connect("enemy_died", enemy_died)
	enemy_scene.detection_collision_radius = detection_collision_radius
	enemy_scene.get_node("EnemyStateMachine").connect_player(player_ref)
	enemy_scene.get_node("EnemyStateMachine/Death").death_particles_Modulate = death_particles_Modulate
	if enemy_sprite:
		enemy_scene.get_node("Sprite2D").texture = enemy_sprite
	enemy_scene.change_radius_detection_collision_shape()
	#$Enemy/EnemyStateMachine.connect_player(player_ref)

func enemy_died():
	spawned_enemy_died.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
