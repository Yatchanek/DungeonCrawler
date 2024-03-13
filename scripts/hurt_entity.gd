extends Node2D
class_name HurtEntity

@export var base_damage : int
@export var current_damage : float
@export var has_knockback : bool = true

func initialize_damage(_damage : int):
	base_damage = _damage
	current_damage = base_damage


	
