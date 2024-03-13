extends Area2D
class_name HitBox

@export var target : CharacterBody2D

func _on_area_entered(area: Area2D) -> void:
	if area is HurtBox:
		if area.attacker is Projectile and area.attacker.collision_exception == self:
			return
		target.take_damage(area.attacker)
