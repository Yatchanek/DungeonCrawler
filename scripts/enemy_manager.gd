extends Node2D

@export var enemy_scenes : Array[PackedScene]

signal enemy_spawned

var enemy_count : int 

var world_state : PhysicsDirectSpaceState2D

func _ready() -> void:
	enemy_count = 0

func _physics_process(_delta: float) -> void:
	world_state = get_world_2d().direct_space_state

func spawn_enemy(coords, top_x, top_y, size_x, size_y):
	var enemy = enemy_scenes.pick_random().instantiate()
	enemy.position = Vector2(randf_range(top_x * 32 + 64, top_x * 32 + size_x * 32 - 64), randf_range(top_y * 32 + 64, top_y * 32 + size_y * 32 - 64))
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
