extends Node2D

var current_damage : int = 2

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area is HitBox:
		area.target.take_damage(self)


func _on_detector_body_entered(body: CharacterBody2D) -> void:
	animation_player.play("Launch")
