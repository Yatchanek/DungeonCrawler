extends Area2D
class_name HitBox

@export var target : CharacterBody2D

func _on_area_entered(area: Area2D) -> void:
	if area is HurtBox:
		target.take_damage(area)
		if area.weapon_node.is_launched:
			area.weapon_node.return_to_hand()
