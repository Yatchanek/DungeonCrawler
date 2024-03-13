extends Weapon
class_name Wand

var projectile_scene = preload("res://scenes/projectile.tscn")

@export var user : CharacterBody2D
@onready var projectile_spawn_position: Marker2D = $ProjectileSpawnPosition


func launch_projectile():
	var projectile : Projectile = projectile_scene.instantiate()
	projectile.global_position = projectile_spawn_position.global_position
	projectile.look_at(EnemyManager.player.global_position + Vector2(0, -20))
	projectile.fired_by = self
	projectile.collision_exception = user
	call_deferred("add_child", projectile)
