extends CharacterBody2D
class_name Enemy
var original_position 
var player_chase
var is_being_hit
var is_being_after_hit

# for after death particles
@onready var death_particles_big: CPUParticles2D = $particles/big
@onready var death_particles_medium: CPUParticles2D = $particles/medium
@onready var death_particles_small: CPUParticles2D = $particles/small
@onready var nav_agent: NavigationAgent2D = $"NavigationAgent2D"
@onready var detection_collision_shape: CollisionShape2D = $DetectionArea/CollisionShape2D
var is_spawned = false
@export var enemy_sprite: Texture
@export var detection_collision_radius: float = 55

var is_dead = false


@export var health = 20

@onready var state_machine = $"EnemyStateMachine"

func _ready() -> void:
	
	original_position = position
	player_chase = false
	if enemy_sprite:
		$Sprite2D.texture = enemy_sprite
	change_radius_detection_collision_shape()


func _spawn_enemy():
	is_spawned = true

func change_radius_detection_collision_shape():
	if detection_collision_shape and detection_collision_shape.shape is CircleShape2D:
		detection_collision_shape.shape.radius = detection_collision_radius

func enemy():
	pass


func take_damage(amount:float, posi, damage_name, knockback):
	print(amount)
	state_machine._transition_to_next_state("BeingHit", {"amount":amount, "posi":posi, "damage_name":damage_name, "knockback":knockback})

#func _check_overlap_with_player():
	#var overlapping_bodies = $DetectionArea.get_overlapping_bodies()
	#for body in overlapping_bodies:
		#print("Overlapping with:", body.name)
		#if body.has_method("player") and state_machine.state != "PlayerChase":
			#state_machine._transition_to_next_state("PlayerChase")
			
func _set_health(amount:float):
	print(str(amount) + "damage done")
	health += amount
	if health<=0:
		health = 0
		print("enemy died")
		state_machine._transition_to_next_state("Death")
		#death_animation()
