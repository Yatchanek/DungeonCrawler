extends Area2D
class_name HurtBox

@export var attacker : CharacterBody2D
@export var weapon_node : Weapon
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func activate():
	collision_shape_2d.set_deferred("disabled", false)
	
func deactivate():
	collision_shape_2d.set_deferred("disabled", true)

