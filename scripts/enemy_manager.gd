extends Node2D

@export var enemy_scenes : Array[PackedScene]

signal enemy_spawned

var enemy_count : int 

var spawn_probability : Dictionary = {
	0: 0.7,
	1: 0.25,
	2: 0.05
}

var world_state : PhysicsDirectSpaceState2D

var player : Player

func _ready() -> void:
	enemy_count = 0
	

func _physics_process(_delta: float) -> void:
	world_state = get_world_2d().direct_space_state

func spawn_enemy(coords, pos):
	var roll : float = randf()
	var total_chance : float = 0.0
	var enemy_scene : PackedScene
	for i in spawn_probability.keys():
		total_chance += spawn_probability[i]
		if roll < total_chance:	
			enemy_scene = enemy_scenes[i]
			break
	if !enemy_scene:
		enemy_scene = enemy_scenes[0]
	var enemy : CharacterBody2D
	enemy = enemy_scene.instantiate()
	enemy.position = pos
	enemy_spawned.emit(enemy, coords)
	enemy.tree_entered.connect(_on_enemy_spawned)
	enemy.tree_exited.connect(_on_enemy_killed)
	

func _on_enemy_spawned():
	enemy_count += 1
	if !is_physics_processing():
		set_physics_process(true)
		
func _on_enemy_killed():
	enemy_count -= 1
	if enemy_count <= 0:
		set_physics_process(false)

func _on_player_ready(_player):
	player = _player
